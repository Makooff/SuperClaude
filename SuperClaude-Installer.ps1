# SuperClaude Installer — Windows
# Double-cliquer Lancer.vbs pour installer sans terminal

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="SuperClaude Installer"
    Width="500" Height="440"
    WindowStartupLocation="CenterScreen"
    ResizeMode="NoResize"
    Background="#09090b">
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <TextBlock Grid.Row="0"
            Text="** SuperClaude"
            Foreground="White"
            FontSize="26"
            FontWeight="Bold"
            FontFamily="Segoe UI"
            HorizontalAlignment="Center"
            Margin="0,0,0,4"/>

        <TextBlock Grid.Row="1"
            Text="Skills + Plugins + MCPs — pret en 1 clic"
            Foreground="#71717a"
            FontSize="12"
            FontFamily="Segoe UI"
            HorizontalAlignment="Center"
            Margin="0,0,0,16"/>

        <Border Grid.Row="2"
            Background="#18181b"
            CornerRadius="6"
            Padding="10"
            Margin="0,0,0,12">
            <ScrollViewer Name="LogScroll" VerticalScrollBarVisibility="Auto">
                <TextBlock Name="LogBox"
                    Foreground="#4ade80"
                    FontFamily="Consolas"
                    FontSize="11"
                    TextWrapping="Wrap"
                    VerticalAlignment="Top"/>
            </ScrollViewer>
        </Border>

        <ProgressBar Grid.Row="3"
            Name="ProgressBar"
            Height="6"
            Minimum="0"
            Maximum="12"
            Value="0"
            Foreground="#7c3aed"
            Background="#27272a"
            Margin="0,0,0,8"/>

        <TextBlock Grid.Row="4"
            Name="StatusLabel"
            Text="Pret a installer"
            Foreground="#71717a"
            FontSize="12"
            FontFamily="Segoe UI"
            Margin="0,0,0,12"/>

        <StackPanel Grid.Row="5" Orientation="Horizontal" HorizontalAlignment="Center">
            <Button Name="InstallButton"
                Content="  Installer  "
                FontSize="14"
                FontFamily="Segoe UI"
                Foreground="White"
                Background="#7c3aed"
                BorderBrush="#7c3aed"
                Padding="24,10"
                Cursor="Hand"
                Margin="0,0,12,0">
                <Button.Style>
                    <Style TargetType="Button">
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="Button">
                                    <Border Background="{TemplateBinding Background}"
                                            CornerRadius="6"
                                            Padding="{TemplateBinding Padding}">
                                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#6d28d9"/>
                                        </Trigger>
                                        <Trigger Property="IsPressed" Value="True">
                                            <Setter Property="Background" Value="#5b21b6"/>
                                        </Trigger>
                                        <Trigger Property="IsEnabled" Value="False">
                                            <Setter Property="Background" Value="#3f3f46"/>
                                            <Setter Property="Foreground" Value="#71717a"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Button.Style>
            </Button>

            <Button Name="OpenButton"
                Content="  Choisir dossier projet ->  "
                FontSize="14"
                FontFamily="Segoe UI"
                Foreground="White"
                Background="#059669"
                BorderBrush="#059669"
                Padding="24,10"
                Cursor="Hand"
                Visibility="Collapsed">
                <Button.Style>
                    <Style TargetType="Button">
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="Button">
                                    <Border Background="{TemplateBinding Background}"
                                            CornerRadius="6"
                                            Padding="{TemplateBinding Padding}">
                                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#047857"/>
                                        </Trigger>
                                        <Trigger Property="IsPressed" Value="True">
                                            <Setter Property="Background" Value="#065f46"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Button.Style>
            </Button>
        </StackPanel>
    </Grid>
</Window>
"@

$reader  = [System.Xml.XmlNodeReader]::new([xml]$xaml)
$window  = [System.Windows.Markup.XamlReader]::Load($reader)

$logBox        = $window.FindName('LogBox')
$progressBar   = $window.FindName('ProgressBar')
$statusLabel   = $window.FindName('StatusLabel')
$installButton = $window.FindName('InstallButton')
$openButton    = $window.FindName('OpenButton')
$logScroll     = $window.FindName('LogScroll')

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Synchronized hashtable for cross-thread communication
$sync = [hashtable]::Synchronized(@{
    Log      = ""
    Progress = 0
    Status   = ""
    Done     = $false
    Error    = ""
})

# Background script — runs in its own Runspace
$bgScript = {
    param($sync, $scriptDir)

    function Step {
        param([int]$n, [string]$label, [scriptblock]$action)
        $sync.Status   = $label
        $sync.Log     += "-> $label`n"
        $sync.Progress = $n
        try {
            & $action
        } catch {
            $sync.Log += "[WARN] $_`n"
        }
    }

    # 1 — Node.js
    Step 1 "Verification Node.js..." {
        $v = node --version 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Node.js non trouve — installer depuis nodejs.org" }
        $sync.Log += "[OK] Node.js $v`n"
    }

    # 2 — Claude Code
    Step 2 "Verification Claude Code..." {
        $v = claude --version 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Claude Code non trouve — installer depuis claude.ai/code" }
        $sync.Log += "[OK] Claude Code $v`n"
    }

    # 3 — Plugin superpowers
    Step 3 "Plugin superpowers..." {
        claude plugin install superpowers 2>&1 | Out-Null
        $sync.Log += "[OK] superpowers installe`n"
    }

    # 4 — Plugin code-review
    Step 4 "Plugin code-review..." {
        claude plugin install code-review 2>&1 | Out-Null
        $sync.Log += "[OK] code-review installe`n"
    }

    # 5 — Plugin caveman
    Step 5 "Plugin caveman..." {
        claude plugin install caveman 2>&1 | Out-Null
        $sync.Log += "[OK] caveman installe`n"
    }

    # 6 — Plugin playwright
    Step 6 "Plugin playwright..." {
        claude plugin install playwright 2>&1 | Out-Null
        $sync.Log += "[OK] playwright installe`n"
    }

    # 7 — Skills locaux (copie globale)
    Step 7 "Copie skills SuperClaude..." {
        $srcSkills  = Join-Path $scriptDir ".claude\skills"
        $destSkills = Join-Path $env:USERPROFILE ".claude\skills"
        if (Test-Path $srcSkills) {
            if (-not (Test-Path $destSkills)) { New-Item -ItemType Directory -Path $destSkills -Force | Out-Null }
            Copy-Item "$srcSkills\*" $destSkills -Force
            $sync.Log += "[OK] Skills copies dans ~/.claude/skills`n"
        } else {
            $sync.Log += "[WARN] Dossier skills non trouve`n"
        }
    }

    # 8 — CLAUDE.md global
    Step 8 "CLAUDE.md global..." {
        $srcMd  = Join-Path $scriptDir "CLAUDE.md"
        $destMd = Join-Path $env:USERPROFILE ".claude\CLAUDE.md"
        if (Test-Path $srcMd) {
            $destDir = Join-Path $env:USERPROFILE ".claude"
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            Copy-Item $srcMd $destMd -Force
            $sync.Log += "[OK] CLAUDE.md copie dans ~/.claude`n"
        } else {
            $sync.Log += "[WARN] CLAUDE.md non trouve`n"
        }
    }

    # 9 — MCP context7
    Step 9 "MCP context7..." {
        claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp 2>&1 | Out-Null
        $sync.Log += "[OK] MCP context7 ajoute`n"
    }

    # 10 — MCP playwright
    Step 10 "MCP playwright..." {
        claude mcp add playwright --scope user -- npx @playwright/mcp@latest 2>&1 | Out-Null
        $sync.Log += "[OK] MCP playwright ajoute`n"
    }

    # 11 — .mcp.json global
    Step 11 "Config MCP globale..." {
        $srcMcp  = Join-Path $scriptDir ".mcp.json"
        $destMcp = Join-Path $env:USERPROFILE ".claude\.mcp.json"
        if (Test-Path $srcMcp) {
            Copy-Item $srcMcp $destMcp -Force
            $sync.Log += "[OK] .mcp.json copie dans ~/.claude`n"
        } else {
            $sync.Log += "[WARN] .mcp.json non trouve`n"
        }
    }

    # 12 — Done
    $sync.Progress = 12
    $sync.Status   = "Installation terminee !"
    $sync.Log     += "`n[OK] SuperClaude installe avec succes !`n"
    $sync.Done     = $true
}

# DispatcherTimer polls sync on UI thread
$timer          = [System.Windows.Threading.DispatcherTimer]::new()
$timer.Interval = [System.TimeSpan]::FromMilliseconds(120)
$timer.add_Tick({
    $logBox.Text       = $sync.Log
    $progressBar.Value = $sync.Progress
    $statusLabel.Text  = $sync.Status
    $logScroll.ScrollToEnd()
    if ($sync.Done) {
        $timer.Stop()
        $openButton.Visibility = [System.Windows.Visibility]::Visible
    }
})

$installButton.Add_Click({
    $installButton.IsEnabled = $false
    $ps = [powershell]::Create()
    [void]$ps.AddScript($bgScript)
    [void]$ps.AddArgument($sync)
    [void]$ps.AddArgument($scriptDir)
    $timer.Start()
    [void]$ps.BeginInvoke()
})

$openButton.Add_Click({
    $picker = [System.Windows.Forms.FolderBrowserDialog]::new()
    $picker.Description = "Choisir le dossier de votre projet Claude"
    if ($picker.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $projectDir = $picker.SelectedPath
        try {
            # Copy .claude/ folder
            $srcClaude  = Join-Path $scriptDir ".claude"
            $destClaude = Join-Path $projectDir ".claude"
            if (Test-Path $srcClaude) {
                Copy-Item $srcClaude $destClaude -Recurse -Force
            }
            # Copy CLAUDE.md
            $srcMd = Join-Path $scriptDir "CLAUDE.md"
            if (Test-Path $srcMd) {
                Copy-Item $srcMd (Join-Path $projectDir "CLAUDE.md") -Force
            }
            # Copy .mcp.json
            $srcMcp = Join-Path $scriptDir ".mcp.json"
            if (Test-Path $srcMcp) {
                Copy-Item $srcMcp (Join-Path $projectDir ".mcp.json") -Force
            }
            # Copy .env.example -> .env.local if not exists
            $srcEnv  = Join-Path $scriptDir ".env.example"
            $destEnv = Join-Path $projectDir ".env.local"
            if ((Test-Path $srcEnv) -and (-not (Test-Path $destEnv))) {
                Copy-Item $srcEnv $destEnv -Force
            }
            # Add .env.local to .gitignore
            $gitignore = Join-Path $projectDir ".gitignore"
            if (Test-Path $gitignore) {
                $content = Get-Content $gitignore -Raw
                if ($content -notmatch "\.env\.local") {
                    Add-Content $gitignore "`n.env.local"
                }
            }
        } catch {
            [System.Windows.MessageBox]::Show("Erreur copie: $_", "SuperClaude", 0, 48)
        }

        # Open Claude Code in project folder
        $claudeExe = @(
            "$env:LOCALAPPDATA\Programs\claude\Claude.exe",
            "$env:PROGRAMFILES\claude\Claude.exe",
            "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"
        ) | Where-Object { Test-Path $_ } | Select-Object -First 1

        if ($claudeExe) {
            Start-Process $claudeExe -WorkingDirectory $projectDir
        } else {
            Start-Process "cmd.exe" -ArgumentList "/k cd /d `"$projectDir`" && claude"
        }
    }
})

[void]$window.ShowDialog()
