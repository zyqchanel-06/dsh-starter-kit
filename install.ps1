<#
.SYNOPSIS
  DSH 新手整合包 · 安装器

.DESCRIPTION
  按"套餐"把技能装进 DSH 的 skill 目录。幂等，可重复跑；已存在的技能默认跳过。

.PARAMETER Preset
  writer     -> 写作 / 内容创作者
  coder      -> 编程 / 开发者
  researcher -> 研究 / 学习 / 出图
  everything -> 我全都要

.PARAMETER Scope
  User    -> <DSH_HOME>\skills      （全局生效，推荐）
  Project -> <项目根>\.dsh\skills   （只对当前目录生效）

.PARAMETER Force
  已存在的同名技能也覆盖。默认跳过。

.PARAMETER DryRun
  只打印计划，不写任何文件。

.PARAMETER List
  只列出所有套餐和各自的技能，不安装。

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\install.ps1 -List

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\install.ps1 -Preset everything -DryRun

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\install.ps1 -Preset coder
#>
[CmdletBinding()]
param(
  [ValidateSet("writer", "coder", "researcher", "everything")]
  [string] $Preset = "everything",

  [ValidateSet("User", "Project")]
  [string] $Scope = "User",

  [string] $ProjectRoot,

  [switch] $Force,
  [switch] $DryRun,
  [switch] $List
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Step($m) { Write-Host "==> $m" -ForegroundColor Cyan }
function Write-Ok($m)   { Write-Host "  OK  $m" -ForegroundColor Green }
function Write-Note($m) { Write-Host "  ..  $m" -ForegroundColor Yellow }
function Write-Bad($m)  { Write-Host "  !!  $m" -ForegroundColor Red }

$kit = Split-Path -Parent $MyInvocation.MyCommand.Path
$presetDir = Join-Path $kit "presets"
$skillSrc = Join-Path $kit "skills"

if (-not (Test-Path $presetDir)) { Write-Bad "找不到 presets 目录，脚本必须放在整合包根目录"; exit 1 }
if (-not (Test-Path $skillSrc)) { Write-Bad "找不到 skills 目录"; exit 1 }

# ---------- -List ----------
if ($List) {
  Write-Step "可用套餐"
  foreach ($f in Get-ChildItem $presetDir -Filter "*.json" | Sort-Object Name) {
    $p = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    Write-Host ""
    Write-Host ("  [{0}]  {1}" -f $p.id, $p.name) -ForegroundColor White
    Write-Host ("         {0}" -f $p.tagline) -ForegroundColor DarkGray
    Write-Host ("         技能 {0} 个 / 插件 {1} 个" -f $p.skills.Count, $p.plugins.Count) -ForegroundColor DarkGray
  }
  Write-Host ""
  Write-Note "用 -Preset <名字> 安装，例如：.\install.ps1 -Preset everything"
  exit 0
}

# ---------- 读套餐 ----------
$presetFile = Join-Path $presetDir ($Preset + ".json")
if (-not (Test-Path $presetFile)) { Write-Bad "找不到套餐 $Preset"; exit 1 }
$cfg = Get-Content $presetFile -Raw -Encoding UTF8 | ConvertFrom-Json

# ---------- 定位目标 ----------
$dshHome = if ($env:DSH_HOME -and $env:DSH_HOME.Trim()) { $env:DSH_HOME.Trim() } else { Join-Path $env:USERPROFILE ".dsh" }

if ($Scope -eq "Project") {
  if (-not $ProjectRoot) {
    $ProjectRoot = (git rev-parse --show-toplevel 2>$null)
    if (-not $ProjectRoot) { $ProjectRoot = (Get-Location).Path }
  }
  $dstSkills = Join-Path $ProjectRoot ".dsh\skills"
} else {
  $dstSkills = Join-Path $dshHome "skills"
}

Write-Step "安装计划"
Write-Host ("  套餐      : {0}（{1}）" -f $cfg.id, $cfg.name)
Write-Host ("  技能来源  : {0}" -f $skillSrc)
Write-Host ("  安装目标  : {0}" -f $dstSkills)
Write-Host ("  覆盖已有  : {0}" -f ([bool]$Force))
if ($DryRun) { Write-Note "DryRun 模式：不会写任何文件" }

# ---------- 复制技能 ----------
Write-Step "安装技能"
$installed = 0; $skipped = 0; $missing = 0; $invalid = @()

foreach ($name in $cfg.skills) {
  $src = Join-Path $skillSrc $name
  if (-not (Test-Path $src)) { Write-Bad "包内缺少技能：$name"; $missing++; continue }

  $dst = Join-Path $dstSkills $name
  if ((Test-Path $dst) -and -not $Force) { Write-Note "跳过（已存在）：$name"; $skipped++; continue }

  # frontmatter 自检：DSH 会静默跳过不合规的技能
  $skillMd = Join-Path $src "SKILL.md"
  if (Test-Path $skillMd) {
    $head = Get-Content $skillMd -TotalCount 8 -Encoding UTF8
    if (-not ($head -match "^name:\s*\S")) { $invalid += $name }
  } else {
    $invalid += "$name（缺 SKILL.md）"
  }

  if (-not $DryRun) {
    if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $dstSkills | Out-Null
    Copy-Item -Path $src -Destination $dst -Recurse -Force
  }
  Write-Ok "$name"
  $installed++
}

# ---------- 汇总 ----------
Write-Step "结果"
Write-Host ("  新装 {0} 个 / 跳过 {1} 个 / 包内缺失 {2} 个" -f $installed, $skipped, $missing)
if ($invalid.Count -gt 0) {
  Write-Bad ("以下技能的 frontmatter 可能不合规（会被静默忽略）：" + ($invalid -join ", "))
}

$total = (Get-ChildItem $dstSkills -Directory -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Host ("  目标目录现有技能总数：{0}" -f $total)

# ---------- 插件指引（不自动安装）----------
if ($cfg.plugins.Count -gt 0) {
  Write-Step "推荐插件（需要你自己决定装不装）"
  foreach ($pl in $cfg.plugins) {
    Write-Host ("  - {0}" -f $pl.id) -ForegroundColor White
    Write-Host ("    为什么：{0}" -f $pl.why) -ForegroundColor DarkGray
  }
  Write-Host ""
  Write-Note "插件是第三方项目，本包不打包其代码。安装方式见 README 的「插件」一节。"
}

# ---------- 下一步 ----------
Write-Step "接下来"
Write-Host "  1) 重启 DSH 或新开一个会话"
Write-Host "  2) 直接说一句「/skills」看技能列表是否出现"
Write-Host "  3) 出问题看 docs/faq.md"
Write-Host ""
Write-Ok "完成"
