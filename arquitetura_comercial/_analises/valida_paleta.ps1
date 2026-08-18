<#
    Port PowerShell do validador de paleta do skill `dataviz`
    (scripts/validate_palette.js). Esta maquina nao tem Node nem Python e o
    navegador esta bloqueado por politica, entao o validador original nao roda
    aqui. Este arquivo reproduz a MESMA matematica e os MESMOS limiares:

      - conversao sRGB -> linear -> OKLab/OKLCH (coeficientes identicos)
      - simulacao de daltonismo Machado-Oliveira-Fernandes (2009), severidade 1.0
      - deltaE = distancia euclidiana em OKLab x100
      - contraste WCAG contra a superficie

    Limiares (identicos ao original):
      BAND light [0.43, 0.77] · dark [0.48, 0.67]   CHROMA_FLOOR 0.10
      CVD_TARGET 8.0 · CVD_FLOOR 6.0 (banda de WARN)  NORMAL_FLOOR 15.0 (gate duro)
      CONTRAST_MIN 3.0 (abaixo = "relief": exige rotulo visivel ou tabela)

    Uso:
      .\valida_paleta.ps1 -Palette '#0E6560,#B4530A' -Mode light -Surface '#FFFFFF' -Pairs all
#>
param(
    [Parameter(Mandatory)][string]$Palette,
    [ValidateSet('light','dark')][string]$Mode = 'light',
    [string]$Surface,
    [ValidateSet('adjacent','all')][string]$Pairs = 'adjacent'
)
$ErrorActionPreference = 'Stop'

$BAND          = @{ light = @(0.43,0.77); dark = @(0.48,0.67) }
$CHROMA_FLOOR  = 0.10
$CVD_TARGET    = 8.0
$CVD_FLOOR     = 6.0
$NORMAL_FLOOR  = 15.0
$CONTRAST_MIN  = 3.0
$DEFAULT_SURF  = @{ light = '#fcfcfb'; dark = '#1a1a19' }

$MACHADO = @{
  protan = @(@(0.152286,1.052583,-0.204868), @(0.114503,0.786281,0.099216),  @(-0.003882,-0.048116,1.051998))
  deutan = @(@(0.367322,0.860646,-0.227968), @(0.280085,0.672501,0.047413),  @(-0.011820,0.042940,0.968881))
  tritan = @(@(1.255528,-0.076749,-0.178779),@(-0.078411,0.930809,0.147602), @(0.004733,0.691367,0.303900))
}

function S2Lin([double]$c){ if($c -le 0.04045){ return $c/12.92 } return [Math]::Pow(($c+0.055)/1.055, 2.4) }

function Lin([string]$hex){
  $h = $hex.Trim().TrimStart('#')
  $rgb = @(0,2,4) | ForEach-Object { [Convert]::ToInt32($h.Substring($_,2),16)/255.0 }
  return @( (S2Lin $rgb[0]), (S2Lin $rgb[1]), (S2Lin $rgb[2]) )
}

function OklabFromLin([double[]]$c){
  $l = [Math]::Pow(0.4122214708*$c[0] + 0.5363325363*$c[1] + 0.0514459929*$c[2], 1.0/3.0)
  $m = [Math]::Pow(0.2119034982*$c[0] + 0.6806995451*$c[1] + 0.1073969566*$c[2], 1.0/3.0)
  $s = [Math]::Pow(0.0883024619*$c[0] + 0.2817188376*$c[1] + 0.6299787005*$c[2], 1.0/3.0)
  # ATENCAO: em PowerShell a virgula liga mais forte que os operadores
  # aritmeticos - sem os parenteses de cada elemento, `a*$x + b*$y, c*$z`
  # constroi um array no meio da conta e a multiplicacao seguinte estoura.
  return @(
    (0.2104542553*$l + 0.7936177850*$m - 0.0040720468*$s),
    (1.9779984951*$l - 2.4285922050*$m + 0.4505937099*$s),
    (0.0259040371*$l + 0.7827717662*$m - 0.8086757660*$s)
  )
}

function Oklch([string]$hex){
  $lab = OklabFromLin (Lin $hex)
  return @( ($lab[0]), ([Math]::Sqrt($lab[1]*$lab[1] + $lab[2]*$lab[2])) )
}

function RelLum([string]$hex){ $c = Lin $hex; return 0.2126*$c[0] + 0.7152*$c[1] + 0.0722*$c[2] }

function Contraste([string]$a,[string]$b){
  $x = RelLum $a; $y = RelLum $b
  $hi = [Math]::Max($x,$y); $lo = [Math]::Min($x,$y)
  return ($hi + 0.05) / ($lo + 0.05)
}

function Simular([string]$hex,[string]$kind){
  $c = Lin $hex; $M = $MACHADO[$kind]
  $out = @()
  for($i=0;$i -lt 3;$i++){
    $v = $M[$i][0]*$c[0] + $M[$i][1]*$c[1] + $M[$i][2]*$c[2]
    $out += [Math]::Max(0.0,[Math]::Min(1.0,$v))
  }
  return $out
}

function DeltaE([string]$h1,[string]$h2,[string]$kind){
  $a = if($kind){ OklabFromLin (Simular $h1 $kind) } else { OklabFromLin (Lin $h1) }
  $b = if($kind){ OklabFromLin (Simular $h2 $kind) } else { OklabFromLin (Lin $h2) }
  return 100.0 * [Math]::Sqrt(
    [Math]::Pow($a[0]-$b[0],2) + [Math]::Pow($a[1]-$b[1],2) + [Math]::Pow($a[2]-$b[2],2))
}

# ── entrada ───────────────────────────────────────────────────────────────────
$cores = @($Palette -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
foreach($c in $cores){ if($c -notmatch '^#?[0-9a-fA-F]{6}$'){ throw "hex invalido: $c" } }
if(-not $Surface){ $Surface = $DEFAULT_SURF[$Mode] }

$lo = $BAND[$Mode][0]; $hi = $BAND[$Mode][1]
$n = $cores.Count
$ok = $true

Write-Host ""
Write-Host ("PALETA: " + ($cores -join ' ')) -ForegroundColor Cyan
Write-Host ("modo $Mode · superficie $Surface · pares $Pairs · $n cores")
Write-Host ("-" * 78)

# 2. faixa de luminosidade
$fora = @()
foreach($c in $cores){ $L = (Oklch $c)[0]; if($L -lt $lo -or $L -gt $hi){ $fora += ("{0} L={1:N3}" -f $c,$L) } }
if($fora.Count){ $ok = $false }
"{0,-22} {1,-6} {2}" -f 'Lightness band', $(if($fora.Count){'FAIL'}else{'PASS'}),
  $(if($fora.Count){ "fora da banda: " + ($fora -join ', ') } else { "todas $n dentro de L $lo-$hi" })

# 3. piso de croma
$baixo = @()
foreach($c in $cores){ $C = (Oklch $c)[1]; if($C -lt $CHROMA_FLOOR){ $baixo += ("{0} C={1:N3}" -f $c,$C) } }
if($baixo.Count){ $ok = $false }
"{0,-22} {1,-6} {2}" -f 'Chroma floor', $(if($baixo.Count){'FAIL'}else{'PASS'}),
  $(if($baixo.Count){ "abaixo do piso (le como cinza): " + ($baixo -join ', ') } else { "todas $n >= $CHROMA_FLOOR" })

# lista de pares
$pl = @()
if($Pairs -eq 'all'){ for($i=0;$i -lt $n;$i++){ for($j=$i+1;$j -lt $n;$j++){ $pl += ,@($i,$j) } } }
else { for($i=0;$i -lt $n-1;$i++){ $pl += ,@($i,$i+1) } }

# 4. separacao sob daltonismo
$worst = $null
foreach($kind in @('protan','deutan')){
  foreach($p in $pl){
    $d = DeltaE $cores[$p[0]] $cores[$p[1]] $kind
    if($worst -eq $null -or $d -lt $worst[0]){ $worst = @($d,$kind,$cores[$p[0]],$cores[$p[1]]) }
  }
}
$tri = 99.0
foreach($p in $pl){ $d = DeltaE $cores[$p[0]] $cores[$p[1]] 'tritan'; if($d -lt $tri){ $tri = $d } }
$wd = if($worst){ $worst[0] } else { 99.0 }
$cvd = if($wd -ge $CVD_TARGET){'PASS'} elseif($wd -ge $CVD_FLOOR){'WARN'} else {'FAIL'}
if($cvd -eq 'FAIL'){ $ok = $false }
"{0,-22} {1,-6} {2}" -f 'CVD separation', $cvd,
  $(if($worst){ "pior par {0}<->{1} dE {2:N1} ({3}) · tritan {4:N1}" -f $worst[3],$worst[2],$wd,$worst[1],$tri } else {'n/a'})

# 4b. piso de visao normal (gate duro)
$nw = $null
foreach($p in $pl){
  $d = DeltaE $cores[$p[0]] $cores[$p[1]] $null
  if($nw -eq $null -or $d -lt $nw[0]){ $nw = @($d,$cores[$p[0]],$cores[$p[1]]) }
}
$nd = if($nw){ $nw[0] } else { 99.0 }
if($nd -lt $NORMAL_FLOOR){ $ok = $false }
"{0,-22} {1,-6} {2}" -f 'Normal-vision floor', $(if($nd -ge $NORMAL_FLOOR){'PASS'}else{'FAIL'}),
  $(if($nw){ "pior par {0}<->{1} dE {2:N1}" -f $nw[2],$nw[1],$nd } else {'n/a'})

# 5. contraste contra a superficie
$fraco = @()
foreach($c in $cores){ $r = Contraste $c $Surface; if($r -lt $CONTRAST_MIN){ $fraco += ("{0} {1:N2}:1" -f $c,$r) } }
"{0,-22} {1,-6} {2}" -f 'Contrast vs surface', $(if($fraco.Count){'RELIEF'}else{'PASS'}),
  $(if($fraco.Count){ "abaixo de ${CONTRAST_MIN}:1 - exige rotulo visivel ou tabela: " + ($fraco -join ', ') } else { "todas $n >= ${CONTRAST_MIN}:1" })

Write-Host ("-" * 78)
if($ok){ Write-Host "RESULTADO: OK" -ForegroundColor Green } else { Write-Host "RESULTADO: FALHOU" -ForegroundColor Red }
Write-Host ""
if(-not $ok){ exit 1 }
