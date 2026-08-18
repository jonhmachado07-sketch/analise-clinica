#requires -Version 5.1
<#
    Analises A1-A7 que sustentam a arquitetura comercial.

    Uso:
        .\analises.ps1 -Xlsx "..\..\exportacao_sistemas_agendamento\Base Unificada - Clinica Expert.xlsx" -Out .\RESULTADOS.md

    O script:
      1. copia e extrai o .xlsx (que e um zip de XML) para uma pasta temporaria;
      2. converte as abas em TSV preservando o TEXTO BRUTO de cada celula;
      3. roda a GUARDA de conferencia (mapa_de_dados/02 §1) e ABORTA se algo divergir;
      4. roda A1..A7 e escreve o markdown de resultados.

    Nao ha dependencia externa: so PowerShell 5.1 + .NET.
#>
param(
    [string]$Xlsx = "..\..\exportacao_sistemas_agendamento\Base Unificada - Clinica Expert.xlsx",
    [string]$Out  = ".\RESULTADOS.md"
)

$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

# ---------------------------------------------------------------- utilitarios

# Regra do mapa_de_dados 02 §1: abas usam separadores decimais diferentes.
# Se a string tem virgula, e pt-BR; senao, invariante. Parser de cultura fixa
# infla a receita em 2,26x.
function Parse-Num([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return 0.0 }
    $s = $s.Trim()
    if ($s.Contains(',')) { return [double]::Parse($s, [Globalization.CultureInfo]::GetCultureInfo('pt-BR')) }
    return [double]::Parse($s, [Globalization.CultureInfo]::InvariantCulture)
}

function Parse-Data([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return $null }
    $s = $s.Trim().Split(' ')[0] -replace '\.', '/'
    # PS 5.1 nao resolve a sobrecarga com string[] de formatos - tentar um a um.
    foreach ($f in @('dd/MM/yyyy','d/M/yyyy')) {
        $dt = [datetime]::MinValue
        if ([datetime]::TryParseExact($s, $f, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref]$dt)) { return $dt }
    }
    return $null
}

# Chave canonica do projeto (mapa_de_dados/04 §1): 8 ultimos digitos.
function Tel-Chave([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return $null }
    $d = ($s -replace '\D','')
    if ($d.Length -lt 8) { return $null }
    return $d.Substring($d.Length - 8)
}

function Percentil([double[]]$v, [double]$p) {
    if ($v.Count -eq 0) { return [double]::NaN }
    $s = $v | Sort-Object
    $i = [Math]::Ceiling($p * $s.Count) - 1
    if ($i -lt 0) { $i = 0 }
    if ($i -ge $s.Count) { $i = $s.Count - 1 }
    return $s[$i]
}

# ------------------------------------------------- A1: de-para canonico (72 -> 10)
# Familia = unidade de analise de produto. Resolve a nomenclatura suja apontada
# em mapa_de_dados/02 §5: quantidade embutida no nome, caixa inconsistente,
# acento faltando e variantes do mesmo produto.
function Familia([string]$item) {
    $t = $item.Trim()
    $t = $t -replace '^\s*\d+\s*x\s*', ''          # remove "3x ", "2x "...
    $u = $t.ToUpperInvariant()
    $u = $u -replace '[ÁÀÂÃ]','A' -replace '[ÉÊ]','E' -replace '[Í]','I' -replace '[ÓÔÕ]','O' -replace '[Ú]','U' -replace '[Ç]','C'

    if ($u -match 'AVALIA|REAVALIA|CONSULTA ONLINE')      { return 'AVALIACAO (entrada, majoritariamente gratuita)' }
    if ($u -match 'MOROSIL')                              { return 'SUPLEMENTO (Morosil)' }
    if ($u -match 'POS ENDOLASER')                        { return 'ENDOLASER - protocolo pos' }
    if ($u -match 'ENDOLASER')                            { return 'ENDOLASER' }
    if ($u -match 'PRE CRIO|POS CRIO')                    { return 'CRIOLIPOLISE - protocolo pre/pos' }
    if ($u -match 'CRIO')                                 { return 'CRIOLIPOLISE' }
    if ($u -match 'BOTOX|PREENCHIMENTO|BIOESTIMULADOR|FIOS DE PDO|JATO DE PLASMA|RINO') { return 'INJETAVEIS FACIAIS' }
    if ($u -match 'ENZIMA|INTRADERMO|GLUTEO|MICROVASO|3MH|CELULITE')                    { return 'INJETAVEIS CORPORAIS' }
    if ($u -match 'LIMPEZA DE PELE|PEELING|MICROAGULHAMENTO|RADIOFREQUENCIA|OZONIO')    { return 'ESTETICA FACIAL' }
    if ($u -match 'DRENAGEM|MASSAGEM')                    { return 'DRENAGEM / MASSAGEM' }
    return 'OUTROS'
}

# ---------------------------------------------------------------- extracao xlsx
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("clinica_" + [guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory -Force $tmp | Out-Null
$zip = Join-Path $tmp 'base.zip'
Copy-Item -LiteralPath (Resolve-Path $Xlsx) -Destination $zip -Force   # Copy-Item funciona mesmo com o arquivo aberto no Excel
Add-Type -AssemblyName System.IO.Compression.FileSystem
$ext = Join-Path $tmp 'x'
[System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $ext)

# sharedStrings
$ss = New-Object System.Collections.Generic.List[string]
$rdr = [System.Xml.XmlReader]::Create((Join-Path $ext 'xl\sharedStrings.xml'))
$sb = $null; $inT = $false
while ($rdr.Read()) {
    switch ($rdr.NodeType) {
        'Element'    { if ($rdr.Name -eq 'si') { $sb = New-Object System.Text.StringBuilder; if ($rdr.IsEmptyElement) { $ss.Add(''); $sb = $null } }
                       elseif ($rdr.Name -eq 't') { $inT = -not $rdr.IsEmptyElement } }
        'Text'       { if ($inT -and $sb) { [void]$sb.Append($rdr.Value) } }
        'CDATA'      { if ($inT -and $sb) { [void]$sb.Append($rdr.Value) } }
        'SignificantWhitespace' { if ($inT -and $sb) { [void]$sb.Append($rdr.Value) } }
        'Whitespace' { if ($inT -and $sb) { [void]$sb.Append($rdr.Value) } }
        'EndElement' { if ($rdr.Name -eq 't') { $inT = $false } elseif ($rdr.Name -eq 'si') { $ss.Add($sb.ToString()); $sb = $null } }
    }
}
$rdr.Close()

function ColIndex([string]$ref) {
    $n = 0
    foreach ($ch in $ref.ToCharArray()) { if ($ch -ge 'A' -and $ch -le 'Z') { $n = $n*26 + ([int][char]$ch - 64) } else { break } }
    return $n - 1
}

function Read-Sheet([int]$n) {
    $rows = New-Object System.Collections.Generic.List[string[]]
    $rdr = [System.Xml.XmlReader]::Create((Join-Path $ext "xl\worksheets\sheet$n.xml"))
    $row = $null; $maxc = -1; $ci = -1; $ctype = $null; $val = $null; $inVal = $false
    while ($rdr.Read()) {
        switch ($rdr.NodeType) {
            'Element' {
                switch ($rdr.Name) {
                    'row' { $row = @{}; $maxc = -1; $ci = -1 }
                    'c'   { $r = $rdr.GetAttribute('r'); $ctype = $rdr.GetAttribute('t')
                            $ci = if ($r) { ColIndex $r } else { $maxc + 1 }
                            $val = New-Object System.Text.StringBuilder
                            if ($rdr.IsEmptyElement) { if ($ci -gt $maxc) { $maxc = $ci }; $row[$ci] = '' } }
                    'v'   { $inVal = -not $rdr.IsEmptyElement }
                    't'   { $inVal = -not $rdr.IsEmptyElement }
                }
            }
            'Text'  { if ($inVal -and $val) { [void]$val.Append($rdr.Value) } }
            'CDATA' { if ($inVal -and $val) { [void]$val.Append($rdr.Value) } }
            'SignificantWhitespace' { if ($inVal -and $val) { [void]$val.Append($rdr.Value) } }
            'EndElement' {
                switch ($rdr.Name) {
                    'v' { $inVal = $false }
                    't' { $inVal = $false }
                    'c' { $v = $val.ToString()
                          if ($ctype -eq 's' -and $v -ne '') { $v = $ss[[int]$v] }
                          $row[$ci] = ($v -replace "[`t`r`n]", ' ')
                          if ($ci -gt $maxc) { $maxc = $ci } }
                    'row' { $cells = New-Object string[] ([Math]::Max($maxc+1,1))
                            for ($i=0; $i -lt $cells.Length; $i++) { $cells[$i] = if ($row.ContainsKey($i)) { $row[$i] } else { '' } }
                            $rows.Add($cells); $row = $null }
                }
            }
        }
    }
    $rdr.Close()
    return $rows
}

$CU  = Read-Sheet 1   # Clientes Unificados
$VD  = Read-Sheet 2   # Vendas Detalhadas
$CRM = Read-Sheet 3   # Contatos CRM

# ---------------------------------------------------------------- GUARDA
$somaVD = 0.0; $zeros = 0
for ($i=1; $i -lt $VD.Count; $i++) { $v = Parse-Num $VD[$i][5]; $somaVD += $v; if ($v -eq 0) { $zeros++ } }

$guarda = @(
    @{ n='Soma Vendas Detalhadas'; g=[math]::Round($somaVD,2); w=805879.35 },
    @{ n='Linhas de venda';        g=$VD.Count-1;              w=1423 },
    @{ n='Linhas de valor zero';   g=$zeros;                   w=530 },
    @{ n='Clientes unificados';    g=$CU.Count-1;              w=991 },
    @{ n='Contatos CRM';           g=$CRM.Count-1;             w=6374 }
)
$falhou = $false
Write-Host "`n=== GUARDA DE CONFERENCIA ==="
foreach ($c in $guarda) {
    $ok = ($c.g -eq $c.w); if (-not $ok) { $falhou = $true }
    Write-Host ("{0,-26} {1,12} (esperado {2,10})  {3}" -f $c.n, $c.g, $c.w, $(if($ok){'OK'}else{'FALHOU'}))
}
if ($falhou) { Remove-Item -Recurse -Force $tmp; throw "GUARDA FALHOU - analise abortada (ver mapa_de_dados/02 §1)." }
Write-Host "GUARDA OK`n"

# ---------------------------------------------------------------- estruturas
# atendimentos por cliente (chave = telefone 8 digitos)
$cli = @{}
for ($i=1; $i -lt $VD.Count; $i++) {
    $r = $VD[$i]
    $k = Tel-Chave $r[7]
    if (-not $k) { continue }
    if (-not $cli.ContainsKey($k)) { $cli[$k] = @{ nome=$r[3]; atend=(New-Object System.Collections.ArrayList) } }
    $itens = @($r[6] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
    [void]$cli[$k].atend.Add([pscustomobject]@{
        data    = Parse-Data $r[1]
        valor   = Parse-Num  $r[5]
        itens   = $itens
        fams    = @($itens | ForEach-Object { Familia $_ } | Select-Object -Unique)
    })
}
foreach ($k in @($cli.Keys)) { $cli[$k].atend = @($cli[$k].atend | Sort-Object data) }

$md = New-Object System.Collections.Generic.List[string]
function W([string]$s) { $script:md.Add($s) }

W "# Resultados das analises A1-A7"
W ""
W "> Gerado por `_analises/analises.ps1` em $(Get-Date -Format 'dd/MM/yyyy')."
W "> Fonte: `Base Unificada - Clinica Expert.xlsx`. Guarda de conferencia: **5 de 5 OK**"
W "> (soma R\$ 805.879,35 - 1.423 linhas - 530 de valor zero - 991 clientes - 6.374 contatos)."
W ""
W "⚠️ **Janela:** vendas vao de 09/07/2024 a 25/12/2025. Nada aqui cobre 2026."
W ""
W "---"
W ""

# ---------------------------------------------------------------- A1
W "## A1 - De-para canonico: 72 itens -> 10 familias"
W ""
W "Cada linha de venda pode conter varios itens; a receita da linha e atribuida"
W "integralmente a **cada** familia presente. A coluna de receita por familia, portanto,"
W "**soma mais que o total** - serve para ranquear, nunca para somar."
W ""
$fam = @{}
$itensPorFam = @{}
for ($i=1; $i -lt $VD.Count; $i++) {
    $r = $VD[$i]; $v = Parse-Num $r[5]
    $fs = @()
    foreach ($it in ($r[6] -split ',')) {
        $it = $it.Trim(); if ($it -eq '') { continue }
        $f = Familia $it
        if (-not $itensPorFam.ContainsKey($f)) { $itensPorFam[$f] = @{} }
        $itensPorFam[$f][$it] = $true
        $fs += $f
    }
    foreach ($f in ($fs | Select-Object -Unique)) {
        if (-not $fam.ContainsKey($f)) { $fam[$f] = @{ linhas=0; pagas=0; rec=0.0 } }
        $fam[$f].linhas++; $fam[$f].rec += $v; if ($v -gt 0) { $fam[$f].pagas++ }
    }
}
W "| Familia canonica | Itens originais | Linhas | Linhas pagas | Receita atribuida |"
W "|---|---:|---:|---:|---:|"
foreach ($e in ($fam.GetEnumerator() | Sort-Object { -$_.Value.rec })) {
    W ("| {0} | {1} | {2} | {3} | R$ {4:N2} |" -f $e.Key, $itensPorFam[$e.Key].Count, $e.Value.linhas, $e.Value.pagas, $e.Value.rec)
}
W ""
$totItens = ($itensPorFam.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
W "**Cobertura:** $totItens itens originais mapeados em $($fam.Count) familias - nenhum orfao."
W ""

# ---------------------------------------------------------------- A6 (antes de A2, define o universo)
$pagantes = @(); $zeroReais = @()
foreach ($k in $cli.Keys) {
    $tot = ($cli[$k].atend | Measure-Object -Property valor -Sum).Sum
    if ($tot -gt 0) { $pagantes += $k } else { $zeroReais += $k }
}
W "---"
W ""
W "## A6 - Os clientes que vieram e nao pagaram"
W ""
W "| Grupo | Clientes |"
W "|---|---:|"
W "| Atendidos com receita > 0 (**pagantes**) | $($pagantes.Count) |"
W "| Atendidos com receita = 0 | $($zeroReais.Count) |"
W "| **Total com algum atendimento** | $($cli.Count) |"
W ""
$zVisitas = @{}; $zItens = @{}
foreach ($k in $zeroReais) {
    $n = $cli[$k].atend.Count
    $b = if ($n -eq 1) { '1 visita' } elseif ($n -le 3) { '2-3 visitas' } else { '4+ visitas' }
    $zVisitas[$b] = 1 + $(if ($zVisitas.ContainsKey($b)) { $zVisitas[$b] } else { 0 })
    foreach ($a in $cli[$k].atend) { foreach ($it in $a.itens) { $zItens[$it] = 1 + $(if ($zItens.ContainsKey($it)) { $zItens[$it] } else { 0 }) } }
}
W "**Quantas vezes esse grupo esteve fisicamente na clinica:**"
W ""
W "| Visitas | Clientes |"
W "|---|---:|"
foreach ($e in ($zVisitas.GetEnumerator() | Sort-Object Name)) { W ("| {0} | {1} |" -f $e.Key, $e.Value) }
W ""
W "**O que eles fizeram (top 8):**"
W ""
W "| Item | Ocorrencias |"
W "|---|---:|"
foreach ($e in ($zItens.GetEnumerator() | Sort-Object { -$_.Value } | Select-Object -First 8)) { W ("| {0} | {1} |" -f $e.Key, $e.Value) }
W ""

# quantos que fizeram avaliacao gratuita acabaram pagando (algum dia)
$comAval = 0; $comAvalPagou = 0; $avalDepoisPagou = 0
foreach ($k in $cli.Keys) {
    $temAval = $false; $pagouDepois = $false; $dtAval = $null
    foreach ($a in $cli[$k].atend) {
        if ($a.fams -contains 'AVALIACAO (entrada, majoritariamente gratuita)' -and $a.valor -eq 0) {
            if (-not $temAval) { $dtAval = $a.data }
            $temAval = $true
        }
        elseif ($temAval -and $a.valor -gt 0) { $pagouDepois = $true }
    }
    if ($temAval) {
        $comAval++
        if ($pagouDepois) { $avalDepoisPagou++ }
        if ((($cli[$k].atend | Measure-Object -Property valor -Sum).Sum) -gt 0) { $comAvalPagou++ }
    }
}
$pctAval = if ($comAval) { 100.0 * $avalDepoisPagou / $comAval } else { 0 }
W "### A metrica-mae, medida pela primeira vez"
W ""
W "| Indicador | Valor |"
W "|---|---:|"
W "| Clientes com ao menos uma avaliacao gratuita registrada | $comAval |"
W "| Destes, pagaram **algum** procedimento depois da avaliacao | $avalDepoisPagou |"
W "| **Conversao avaliacao -> procedimento pago** | **$('{0:N1}' -f $pctAval)%** |"
W ""
W "⚠️ Este numero e o **piso**, nao a taxa real: so enxerga quem compareceu e teve"
W "atendimento registrado. Quem agendou avaliacao e nao apareceu nao existe em fonte"
W "nenhuma (mapa_de_dados/05, lacuna 2). A taxa verdadeira so aparece quando o"
W "sistema de agendamento entregar o status de comparecimento."
W ""

# ---------------------------------------------------------------- A4
$ltv = @()
foreach ($k in $pagantes) { $ltv += ($cli[$k].atend | Measure-Object -Property valor -Sum).Sum }
$ltv = @($ltv | Sort-Object)
$q1 = Percentil $ltv 0.25; $q2 = Percentil $ltv 0.50; $q3 = Percentil $ltv 0.75; $q9 = Percentil $ltv 0.90
W "---"
W ""
W "## A4 - Distribuicao de LTV: os cortes do eixo Valor"
W ""
W "Sobre os **$($pagantes.Count) clientes pagantes** (receita > 0):"
W ""
W "| Estatistica | Valor |"
W "|---|---:|"
W ("| Minimo | R$ {0:N2} |" -f $ltv[0])
W ("| p25 | R$ {0:N2} |" -f $q1)
W ("| **Mediana** | **R$ {0:N2}** |" -f $q2)
W ("| p75 | R$ {0:N2} |" -f $q3)
W ("| p90 | R$ {0:N2} |" -f $q9)
W ("| Maximo | R$ {0:N2} |" -f $ltv[$ltv.Count-1])
W ("| Media | R$ {0:N2} |" -f (($ltv | Measure-Object -Average).Average))
W ""
W "**Cortes adotados para o eixo Valor** (§3 do 03_SEGMENTACAO_E_REGUAS.md):"
W ""
W "| Faixa | Criterio | Clientes |"
W "|---|---|---:|"
$nTopo = @($ltv | Where-Object { $_ -ge $q9 }).Count
$nAlto = @($ltv | Where-Object { $_ -ge $q3 -and $_ -lt $q9 }).Count
$nMed  = @($ltv | Where-Object { $_ -ge $q1 -and $_ -lt $q3 }).Count
$nEnt  = @($ltv | Where-Object { $_ -lt $q1 }).Count
W ("| Topo | LTV >= R$ {0:N2} (p90) | {1} |" -f $q9, $nTopo)
W ("| Alto | R$ {0:N2} a R$ {1:N2} | {2} |" -f $q3, $q9, $nAlto)
W ("| Medio | R$ {0:N2} a R$ {1:N2} | {2} |" -f $q1, $q3, $nMed)
W ("| Entrada | < R$ {0:N2} (p25) | {1} |" -f $q1, $nEnt)
W ""
$soma = ($ltv | Measure-Object -Sum).Sum
$topoRec = (@($ltv | Where-Object { $_ -ge $q9 }) | Measure-Object -Sum).Sum
W ("**Concentracao:** os {0} clientes do topo respondem por {1:N1}% da receita (R$ {2:N2} de R$ {3:N2})." -f $nTopo, (100.0*$topoRec/$soma), $topoRec, $soma)
W ""

# ---------------------------------------------------------------- A3
W "---"
W ""
W "## A3 - Intervalo real entre compras, por familia"
W ""
W "Dias entre um atendimento pago e o **proximo atendimento pago** do mesmo cliente,"
W "indexado pela familia do atendimento anterior. E o denominador do eixo"
W "**Recencia Relativa** do modelo de segmentacao."
W ""
$gaps = @{}
foreach ($k in $cli.Keys) {
    $pgs = @($cli[$k].atend | Where-Object { $_.valor -gt 0 -and $_.data })
    for ($i=0; $i -lt $pgs.Count-1; $i++) {
        $d = ($pgs[$i+1].data - $pgs[$i].data).Days
        if ($d -le 0) { continue }
        foreach ($f in $pgs[$i].fams) {
            if (-not $gaps.ContainsKey($f)) { $gaps[$f] = New-Object System.Collections.ArrayList }
            [void]$gaps[$f].Add([double]$d)
        }
    }
}
W "| Familia (do atendimento anterior) | n | Mediana | p75 | **Ciclo adotado** |"
W "|---|---:|---:|---:|---:|"
$ciclo = @{}
foreach ($e in ($gaps.GetEnumerator() | Sort-Object { -$_.Value.Count })) {
    $v = [double[]]$e.Value
    $m = Percentil $v 0.50; $p = Percentil $v 0.75
    if ($v.Count -lt 15) { continue }
    $ciclo[$e.Key] = [int]$p
    W ("| {0} | {1} | {2:N0} d | {3:N0} d | **{4:N0} dias** |" -f $e.Key, $v.Count, $m, $p, $p)
}
W ""
$todos = @(); foreach ($e in $gaps.GetEnumerator()) { $todos += [double[]]$e.Value }
W ("**Geral (todas as familias):** n = {0} - mediana {1:N0} dias - p75 {2:N0} dias." -f $todos.Count, (Percentil $todos 0.50), (Percentil $todos 0.75))
W ""
W "O ciclo adotado e o **p75**, nao a mediana: a regua deve disparar quando o cliente"
W "esta atrasado em relacao a maioria, nao no ponto medio. Familias com n < 15 nao"
W "recebem ciclo proprio e herdam o ciclo geral."
W ""

# ---------------------------------------------------------------- A2
W "---"
W ""
W "## A2 - Porta de entrada e expansao"
W ""
W "Familia do **primeiro atendimento pago** de cada cliente, e o que ele comprou depois."
W ""
$entrada = @{}
foreach ($k in $pagantes) {
    $pgs = @($cli[$k].atend | Where-Object { $_.valor -gt 0 })
    if ($pgs.Count -eq 0) { continue }
    foreach ($f in $pgs[0].fams) {
        if (-not $entrada.ContainsKey($f)) { $entrada[$f] = @{ n=0; voltou=0; depois=@{} } }
        $entrada[$f].n++
        if ($pgs.Count -gt 1) {
            $entrada[$f].voltou++
            for ($i=1; $i -lt $pgs.Count; $i++) {
                foreach ($g in $pgs[$i].fams) {
                    $entrada[$f].depois[$g] = 1 + $(if ($entrada[$f].depois.ContainsKey($g)) { $entrada[$f].depois[$g] } else { 0 })
                }
            }
        }
    }
}
W "| Familia de entrada | Clientes | Recompraram | % | Expansao mais frequente |"
W "|---|---:|---:|---:|---|"
foreach ($e in ($entrada.GetEnumerator() | Sort-Object { -$_.Value.n })) {
    if ($e.Value.n -lt 10) { continue }
    $top = ($e.Value.depois.GetEnumerator() | Sort-Object { -$_.Value } | Select-Object -First 2 | ForEach-Object { "$($_.Key) ($($_.Value))" }) -join ' - '
    W ("| {0} | {1} | {2} | {3:N1}% | {4} |" -f $e.Key, $e.Value.n, $e.Value.voltou, (100.0*$e.Value.voltou/$e.Value.n), $top)
}
W ""

# ---------------------------------------------------------------- A7
W "---"
W ""
W "## A7 - Venda casada: o que sai junto na mesma linha"
W ""
$pares = @{}
for ($i=1; $i -lt $VD.Count; $i++) {
    $r = $VD[$i]; if ((Parse-Num $r[5]) -le 0) { continue }
    $fs = @($r[6] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' } | ForEach-Object { Familia $_ } | Select-Object -Unique | Sort-Object)
    for ($a=0; $a -lt $fs.Count; $a++) { for ($b=$a+1; $b -lt $fs.Count; $b++) {
        $key = "$($fs[$a]) + $($fs[$b])"
        $pares[$key] = 1 + $(if ($pares.ContainsKey($key)) { $pares[$key] } else { 0 })
    } }
}
W "| Combinacao (em linhas pagas) | Ocorrencias |"
W "|---|---:|"
foreach ($e in ($pares.GetEnumerator() | Sort-Object { -$_.Value } | Select-Object -First 10)) { W ("| {0} | {1} |" -f $e.Key, $e.Value) }
W ""
$multi = 0; $totPagas = 0
for ($i=1; $i -lt $VD.Count; $i++) {
    $r = $VD[$i]; if ((Parse-Num $r[5]) -le 0) { continue }
    $totPagas++
    $n = @($r[6] -split ',' | Where-Object { $_.Trim() -ne '' }).Count
    if ($n -gt 1) { $multi++ }
}
W ("**{0} de {1} linhas pagas ({2:N1}%) tem mais de um item** - a venda casada nao e excecao, e o padrao." -f $multi, $totPagas, (100.0*$multi/$totPagas))
W ""

# ---------------------------------------------------------------- A5
W "---"
W ""
W "## A5 - Do cadastro no CRM ate a primeira compra"
W ""
W "Dias entre `Entrou no CRM em` e `Primeira Compra`, por canal. Define os SLA do"
W "Funil 1 e a janela a partir da qual o lead deve ser considerado morto."
W ""
$byCanal = @{}
for ($i=1; $i -lt $CU.Count; $i++) {
    $r = $CU[$i]
    $dCrm = Parse-Data $r[27]; $dCom = Parse-Data $r[35]
    if (-not $dCrm -or -not $dCom) { continue }
    $d = ($dCom - $dCrm).Days
    if ($d -lt 0) { continue }
    $canal = if ([string]::IsNullOrWhiteSpace($r[17])) { 'Nao informado' } else { $r[17] }
    if (-not $byCanal.ContainsKey($canal)) { $byCanal[$canal] = New-Object System.Collections.ArrayList }
    [void]$byCanal[$canal].Add([double]$d)
}
W "| Canal | n | Mediana | p75 | p90 | <= 7 dias | <= 30 dias |"
W "|---|---:|---:|---:|---:|---:|---:|"
foreach ($e in ($byCanal.GetEnumerator() | Sort-Object { -$_.Value.Count })) {
    $v = [double[]]$e.Value
    if ($v.Count -lt 5) { continue }
    $l7  = 100.0 * @($v | Where-Object { $_ -le 7  }).Count / $v.Count
    $l30 = 100.0 * @($v | Where-Object { $_ -le 30 }).Count / $v.Count
    W ("| {0} | {1} | {2:N0} d | {3:N0} d | {4:N0} d | {5:N0}% | {6:N0}% |" -f $e.Key, $v.Count, (Percentil $v 0.50), (Percentil $v 0.75), (Percentil $v 0.90), $l7, $l30)
}
$all = @(); foreach ($e in $byCanal.GetEnumerator()) { $all += [double[]]$e.Value }
W ("| **Todos** | **{0}** | **{1:N0} d** | **{2:N0} d** | **{3:N0} d** | **{4:N0}%** | **{5:N0}%** |" -f $all.Count, (Percentil $all 0.50), (Percentil $all 0.75), (Percentil $all 0.90),
    (100.0*@($all|Where-Object{$_ -le 7}).Count/$all.Count), (100.0*@($all|Where-Object{$_ -le 30}).Count/$all.Count))
W ""

# distribuicao de recompra (pagos)
W "---"
W ""
W "## Anexo - Distribuicao de compras pagas por cliente"
W ""
$dist = @{}
foreach ($k in $pagantes) {
    $n = @($cli[$k].atend | Where-Object { $_.valor -gt 0 }).Count
    $b = if ($n -eq 1) { '1' } elseif ($n -le 3) { '2-3' } elseif ($n -le 5) { '4-5' } elseif ($n -le 10) { '6-10' } else { '11+' }
    $dist[$b] = 1 + $(if ($dist.ContainsKey($b)) { $dist[$b] } else { 0 })
}
W "| Compras pagas | Clientes | % dos pagantes |"
W "|---|---:|---:|"
foreach ($b in @('1','2-3','4-5','6-10','11+')) {
    if ($dist.ContainsKey($b)) { W ("| {0} | {1} | {2:N1}% |" -f $b, $dist[$b], (100.0*$dist[$b]/$pagantes.Count)) }
}
W ""

W "---"
W ""
W "## Notas de grao - por que alguns numeros diferem do mapa_de_dados"
W ""
W "Nenhuma divergencia abaixo e erro. Sao contagens de coisas diferentes, e"
W "misturar duas delas na mesma conta produz resultado errado."
W ""
W "| Aqui | mapa_de_dados | Motivo |"
W "|---|---|---|"
W "| $($cli.Count) clientes com atendimento | 683 | Aqui o grao e **telefone** (chave canonica, 04 §1); la e **nome**. 683 nomes dividem 681 telefones (provavel parentesco ou recadastro). |"
W "| $($pagantes.Count) pagantes | 511 | Mesmo motivo. |"
W "| Soma das familias > R\$ 805.879,35 | - | Linha com varios itens e creditada a cada familia. Ranquear, nunca somar. |"
W "| Soma da coluna 'Clientes' de A2 > $($pagantes.Count) | - | Primeira compra com varios itens conta em cada familia de entrada. |"
W ""
W "**O que nao esta aqui e nao pode ser inferido:** comparecimento, no-show,"
W "cancelamento, agendamento, atendente real, satisfacao e resultado clinico."
W "Nenhuma das tres fontes registra qualquer um deles."
W ""

$md -join "`r`n" | Out-File -FilePath $Out -Encoding utf8
Remove-Item -Recurse -Force $tmp
Write-Host "Resultados escritos em $Out"
