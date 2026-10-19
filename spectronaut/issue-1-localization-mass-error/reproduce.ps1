# Reproduces the experiment of issue #1 from the PRIDE files of PXD071048 (DMSOpi-1.raw and its FASTA, downloaded).
#  1. writes the run as BGMS (Spectronaut's documented generic MS format, via the BGSRawAPI.dll Spectronaut ships):
#     once unchanged, and once per shift with the fragments in fragments.tsv.zip moved by that many ppm
#  2. builds a spectral library from the unchanged run with Spectronaut 20.1 (directDIA)
#  3. analyses every BGMS file with that library in Spectronaut 20.1 and 21.1
# Then: python extract_shifts.py <Work>
#
# Requires PowerShell 7. Settings: in the Spectronaut GUI, copy the shipped schemas directDIA "BGS Phospho PTM Workflow"
# and analysis "BGS PTMs - Sparse", set PTM Workflow > PTM Localization > Probability Cutoff to 0 in both, export them
# as .prop. Report schema: ion level, with EG.ModifiedSequence, FG.Charge, EG.ApexRT, EG.PTMLocalizationProbabilities.
param(
  [Parameter(Mandatory)] [string]$Raw,
  [Parameter(Mandatory)] [string]$Fasta,
  [Parameter(Mandatory)] [string]$Work,
  [string]$DirectDiaSettings, [string]$DiaSettings, [string]$ReportSchema,
  [string]$Sn20Bin = 'C:\Program Files (x86)\Biognosys\Spectronaut_v20.1.250624.92449\bin',
  [string]$Sn21Bin = 'C:\Program Files (x86)\Biognosys\Spectronaut_v21\bin',
  [double[]]$Deltas = @(-4.5, -3, 3, 4.5),
  [switch]$BgmsOnly
)
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force $Work | Out-Null

# --- BGMS writing -----------------------------------------------------------------------------------------------------
# BGSRawAPI serializes the file's metadata with BinaryFormatter; Spectronaut 21 ships the package that provides it on
# .NET 9+, so the writer is loaded together with that package in a load context of its own.
[AppContext]::SetSwitch('System.Runtime.Serialization.EnableUnsafeBinaryFormatterSerialization', $true)
$alc = [System.Runtime.Loader.AssemblyLoadContext]::new('bgsrawapi', $false)
$null = $alc.LoadFromAssemblyPath("$Sn21Bin\System.Runtime.Serialization.Formatters.dll")
$enums = $alc.LoadFromAssemblyPath("$Sn21Bin\BGSMSEnums.dll")
$api = $alc.LoadFromAssemblyPath("$Sn21Bin\BGSRawAPI.dll")
$thermo = @("$Sn21Bin\ThermoFisher.CommonCore.Data.dll", "$Sn21Bin\ThermoFisher.CommonCore.RawFileReader.dll")
foreach ($t in $thermo) { $null = [System.Reflection.Assembly]::LoadFrom($t) }

Add-Type -ReferencedAssemblies ($thermo + @('System.Runtime', 'System.Collections', 'System.Linq', 'netstandard')) -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using ThermoFisher.CommonCore.Data.Business;
using ThermoFisher.CommonCore.Data.FilterEnums;
using ThermoFisher.CommonCore.RawFileReader;

public static class ShiftedBgms
{
    // A fragment to move: in every MS2 scan with start <= RT <= end whose isolation window contains the precursor m/z,
    // the most intense centroid within tol ppm of mz is moved by the shift (ppm, relative to where it was observed).
    // A centroid is moved at most once; an m/z listed twice for one scan (isomers sharing an ion) is applied once.
    sealed class Row { public double Mz, Tol, Start, End, Prec; }

    public static string Write(string raw, string dest, string fragmentsTsv, double shiftPpm, Assembly api, Assembly enums)
    {
        var inv = CultureInfo.InvariantCulture;
        var rows = new List<Row>();
        if (!string.IsNullOrEmpty(fragmentsTsv))
        {
            var lines = File.ReadAllLines(fragmentsTsv);
            var h = lines[0].Split('\t').ToList();
            int cMz = h.IndexOf("mz"), cTol = h.IndexOf("tol_ppm"), cS = h.IndexOf("rt_start"), cE = h.IndexOf("rt_end"), cP = h.IndexOf("precursor_mz");
            foreach (var l in lines.Skip(1).Where(x => x.Length > 0))
            {
                var f = l.Split('\t');
                rows.Add(new Row { Mz = double.Parse(f[cMz], inv), Tol = double.Parse(f[cTol], inv), Start = double.Parse(f[cS], inv),
                                   End = double.Parse(f[cE], inv), Prec = double.Parse(f[cP], inv) });
            }
        }
        var order = rows.Select((r, i) => (r, i)).OrderBy(x => x.r.Start).ToArray();
        double maxSpan = rows.Count == 0 ? 0 : rows.Max(r => r.End - r.Start);

        Type tW = api.GetType("BGSRawAPI.BGSRawFileWriter"), tE = api.GetType("BGSRawAPI.ScanEvent"), tP = api.GetType("BGSRawAPI.PrecursorSelection");
        Type tLevel = enums.GetType("BGSMSEnums.MSLevel"), tAnalyzer = enums.GetType("BGSMSEnums.MassAnalyzerType"), tCell = enums.GetType("BGSMSEnums.FragmentationCellType");

        using var rf = RawFileReaderAdapter.FileFactory(raw);
        rf.SelectInstrument(Device.MS, 1);
        var instrument = rf.GetInstrumentData();
        var writer = Activator.CreateInstance(tW, "Thermo", instrument.Model ?? "Unknown", instrument.SerialNumber ?? "Unknown",
            rf.FileHeader.CreationDate, Enum.Parse(enums.GetType("BGSMSEnums.MSMethodType"), "HRM"), raw, dest, true, true);
        var addScan = tW.GetMethod("AddScan");
        int scans = 0, applied = 0, moved = 0;
        for (int s = rf.RunHeaderEx.FirstSpectrum; s <= rf.RunHeaderEx.LastSpectrum; s++)
        {
            var ev = rf.GetScanEventForScanNumber(s);
            int level = ev.MSOrder == MSOrderType.Ms ? 1 : ev.MSOrder == MSOrderType.Ms2 ? 2 : 0;
            if (level == 0) continue;
            double rt = rf.RetentionTimeFromScanNumber(s);
            var stats = rf.GetScanStatsForScanNumber(s);
            double lo = stats.LowMass, hi = stats.HighMass;          // MS1 scans carry their scan range as window
            if (level == 2)
            {
                var re = ev.GetReaction(0);
                lo = re.PrecursorMass - re.IsolationWidth / 2 + re.IsolationWidthOffset;
                hi = re.PrecursorMass + re.IsolationWidth / 2 + re.IsolationWidthOffset;
            }
            var cs = rf.GetCentroidStream(s, false);
            double[] mz = cs.Masses ?? new double[0];
            double[] it = cs.Intensities ?? new double[0];

            if (level == 2 && order.Length > 0)
            {
                var hits = new List<int>();
                int a = 0, b = order.Length;
                while (a < b) { int m = (a + b) / 2; if (order[m].r.Start < rt - maxSpan) a = m + 1; else b = m; }
                for (int k = a; k < order.Length && order[k].r.Start <= rt; k++)
                {
                    var r = order[k].r;
                    if (rt <= r.End && r.Prec >= lo && r.Prec < hi) hits.Add(order[k].i);
                }
                if (hits.Count > 0)
                {
                    hits.Sort();
                    var shifted = (double[])mz.Clone();
                    var claimed = new HashSet<int>();
                    var targets = new HashSet<long>();
                    foreach (int ri in hits)
                    {
                        var r = rows[ri];
                        if (!targets.Add((long)Math.Round(r.Mz * 1e4))) continue;
                        applied++;
                        double tol = r.Mz * r.Tol * 1e-6;
                        int p = Array.BinarySearch(mz, r.Mz - tol); if (p < 0) p = ~p;
                        int best = -1;
                        for (; p < mz.Length && mz[p] <= r.Mz + tol; p++) if (best < 0 || it[p] > it[best]) best = p;
                        if (best < 0 || !claimed.Add(best)) continue;
                        shifted[best] = mz[best] * (1.0 + shiftPpm * 1e-6);
                        moved++;
                    }
                    var idx = Enumerable.Range(0, mz.Length).OrderBy(i => shifted[i]).ToArray();
                    mz = idx.Select(i => shifted[i]).ToArray();
                    it = idx.Select(i => it[i]).ToArray();
                }
            }

            var peaks = new float[2, mz.Length];
            for (int i = 0; i < mz.Length; i++) { peaks[0, i] = (float)mz[i]; peaks[1, i] = (float)it[i]; }
            var sel = Array.CreateInstance(tP, 1);
            sel.SetValue(Activator.CreateInstance(tP, lo, hi), 0);
            var scan = Activator.CreateInstance(tE, peaks, rt, Enum.Parse(tLevel, level == 1 ? "MS1" : "MS2"), true, sel);
            string an = ev.MassAnalyzer.ToString();
            string analyzer = an.Contains("AST") ? "Astral" : an.Contains("FTMS") ? "Orbitrap" : an.Contains("TOF") ? "TOF" : an.Contains("ITMS") ? "IonTrap" : "Unknown";
            tE.GetProperty("MassAnalyzerType").SetValue(scan, Enum.Parse(tAnalyzer, analyzer));
            tE.GetProperty("FragmentationType").SetValue(scan, Enum.Parse(tCell, level == 2 ? "HCD" : "Unknown"));
            addScan.Invoke(writer, new[] { scan });
            scans++;
        }
        tW.GetMethod("Finalize", new[] { typeof(bool) }).Invoke(writer, new object[] { false });
        return $"{dest}: {scans} scans, fragment rows applied {applied} times, {moved} centroids moved by {shiftPpm} ppm";
    }
}
'@

Expand-Archive -Path (Join-Path $PSScriptRoot 'fragments.tsv.zip') -DestinationPath $Work -Force
$fragments = Join-Path $Work 'fragments.tsv'
[ShiftedBgms]::Write($Raw, "$Work\run_d0.bgms", $null, 0, $api, $enums)
foreach ($d in $Deltas) {
  $tag = '{0:+0.###;-0.###}' -f $d
  [ShiftedBgms]::Write($Raw, "$Work\run_d$tag.bgms", $fragments, $d, $api, $enums)
}
if ($BgmsOnly) { return }

# --- Spectronaut ------------------------------------------------------------------------------------------------------
function Spectronaut([string]$Bin, [string]$Out, [string[]]$Arguments) {
  New-Item -ItemType Directory -Force $Out | Out-Null
  Push-Location $Bin
  & dotnet Spectronaut.dll @Arguments -o $Out -setTemp "$Out\tmp" *> "$Out\spectronaut.log"
  Pop-Location
  if (Select-String -Path "$Out\spectronaut.log" -Pattern 'Unrecognized|Invalid command-line' -Quiet) { throw "Spectronaut did not accept the command line, see $Out\spectronaut.log" }
}

# library from the unchanged run
Spectronaut $Sn20Bin "$Work\library" @('direct', '-n', 'library', '-r', $Raw, '-fasta', $Fasta, '-s', $DirectDiaSettings, '-rs', $ReportSchema)
$kit = (Get-ChildItem "$Work\library" -Recurse -Filter *.kit | Select-Object -First 1).FullName

# every file in both versions, same library and settings
foreach ($tag in @('0') + ($Deltas | ForEach-Object { '{0:+0.###;-0.###}' -f $_ })) {
  foreach ($v in @(@{ Tag = 'v20.1'; Bin = $Sn20Bin }, @{ Tag = 'v21.1'; Bin = $Sn21Bin })) {
    Spectronaut $v.Bin "$Work\d$($tag)_$($v.Tag)" @('diaanalysis', '-n', "d$($tag)_$($v.Tag)", '-r', "$Work\run_d$tag.bgms",
      '-a', $kit, '-fasta', $Fasta, '-s', $DiaSettings, '-rs', $ReportSchema)
  }
}
