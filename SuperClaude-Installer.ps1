# SuperClaude Installer — Windows
# Double-cliquer pour installer (clic droit → Exécuter avec PowerShell)

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="SuperClaude Installer"
    Width="480" Height="420"
    WindowStartupLocation="CenterScreen"
    ResizeMode="NoResize"
    Background="#1a1a2e">
    <Grid Margin="24">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- Logo -->
        <TextBlock Grid.Row="0"
            Text="⚡ SuperClaude"
            Foreground="White"
            FontSize="26"
            FontWeight="Bold"
            FontFamily="Segoe UI"
            HorizontalAlignment="Center"
            Margin="0,0,0,4"/>

        <!-- Subtitle -->
        <TextBlock Grid.Row="1"
            Text="Config Claude Code — skills, MCPs, mémoire Obsidian"
            Foreground="#8888aa"
            FontSize="12"
            FontFamily="Segoe UI"
            HorizontalAlignment="Center"
            Margin="0,0,0,16"/>

        <!-- Log area -->
        <Border Grid.Row="2"
            Background="#0d0d1a"
            CornerRadius="6"
            Padding="10"
            Margin="0,0,0,12">
            <ScrollViewer Name="LogScroll" VerticalScrollBarVisibility="Auto">
                <TextBlock Name="LogBox"
                    Foreground="#00ff88"
                    FontFamily="Consolas"
                    FontSize="12"
                    TextWrapping="Wrap"
                    VerticalAlignment="Top"/>
            </ScrollViewer>
        </Border>

        <!-- Progress bar -->
        <ProgressBar Grid.Row="3"
            Name="ProgressBar"
            Height="8"
            Minimum="0"
            Maximum="10"
            Value="0"
            Foreground="#7c3aed"
            Background="#2a2a4a"
            Margin="0,0,0,8"/>

        <!-- Status label -->
        <TextBlock Grid.Row="4"
            Name="StatusLabel"
            Text="Prêt à installer"
            Foreground="#8888aa"
            FontSize="12"
            FontFamily="Segoe UI"
            Margin="0,0,0,12"/>

        <!-- Buttons -->
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
                                            <Setter Property="Background" Value="#3a3a5a"/>
                                            <Setter Property="Foreground" Value="#666688"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Button.Style>
            </Button>

            <Button Name="OpenClaudeButton"
                Content="  Ouvrir Claude Code  "
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

$reader = [System.Xml.XmlNodeReader]::new([xml]$xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$logBox         = $window.FindName('LogBox')
$progressBar    = $window.FindName('ProgressBar')
$statusLabel    = $window.FindName('StatusLabel')
$installButton  = $window.FindName('InstallButton')
$openButton     = $window.FindName('OpenClaudeButton')
$logScroll      = $window.FindName('LogScroll')

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $prefix = switch ($Level) {
        "OK"   { "✅" }
        "WARN" { "⚠️ " }
        "ERR"  { "❌" }
        default { "→ " }
    }
    $line = "[$timestamp] $prefix $Message`n"
    $window.Dispatcher.Invoke([action]{
        $logBox.Text += $line
        $logScroll.ScrollToEnd()
    })
}

function Set-Status {
    param([string]$Text)
    $window.Dispatcher.Invoke([action]{
        $statusLabel.Text = $Text
    })
}

function Set-Progress {
    param([int]$Value)
    $window.Dispatcher.Invoke([action]{
        $progressBar.Value = $Value
    })
}

function Run-Step {
    param(
        [int]$Step,
        [string]$Label,
        [scriptblock]$Action
    )
    Set-Status $Label
    Write-Log $Label
    try {
        & $Action
        Write-Log $Label -Level "OK"
    } catch {
        Write-Log "Avertissement: $_" -Level "WARN"
    }
    Set-Progress $Step
    Start-Sleep -Milliseconds 700
}

$installButton.Add_Click({
    $installButton.IsEnabled = $false

    $job = [System.Threading.Thread]::new([System.Threading.ThreadStart]{

        # Étape 1 — Node.js
        Run-Step 1 "Vérification Node.js..." {
            $v = & node --version 2>&1
            if ($LASTEXITCODE -ne 0) { throw "Node.js non trouvé" }
            Write-Log "Node.js $v détecté"
        }

        # Étape 2 — Claude Code
        Run-Step 2 "Vérification Claude Code..." {
            $v = & claude --version 2>&1
            if ($LASTEXITCODE -ne 0) { throw "claude CLI non trouvé" }
            Write-Log "Claude Code $v détecté"
        }

        # Étape 3 — Plugin code-review
        Run-Step 3 "Installation plugin code-review..." {
            & claude plugin install code-review 2>&1 | Out-Null
        }

        # Étape 4 — Plugin superpowers
        Run-Step 4 "Installation plugin superpowers..." {
            & claude plugin install superpowers 2>&1 | Out-Null
        }

        # Étape 5 — Plugin impeccable
        Run-Step 5 "Installation plugin impeccable..." {
            & claude plugin install impeccable 2>&1 | Out-Null
        }

        # Étape 6 — Plugin taste-skill
        Run-Step 6 "Installation plugin taste-skill..." {
            & claude plugin install taste-skill 2>&1 | Out-Null
        }

        # Étape 7 — Plugin playwright
        Run-Step 7 "Installation plugin playwright..." {
            & claude plugin install playwright 2>&1 | Out-Null
        }

        # Étape 8 — MCP context7
        Run-Step 8 "Ajout MCP context7..." {
            & claude mcp add context7 2>&1 | Out-Null
        }

        # Étape 9 — MCP playwright
        Run-Step 9 "Ajout MCP playwright..." {
            & claude mcp add playwright 2>&1 | Out-Null
        }

        # Étape 10 — Terminé
        Set-Progress 10
        Set-Status "✅ Installation terminée !"
        Write-Log "Installation terminée avec succès !" -Level "OK"

        $window.Dispatcher.Invoke([action]{
            $openButton.Visibility = [System.Windows.Visibility]::Visible
        })
    })

    $job.IsBackground = $true
    $job.Start()
})

$openButton.Add_Click({
    try {
        Start-Process "claude"
    } catch {
        [System.Windows.MessageBox]::Show(
            "Tape 'claude' dans un terminal pour démarrer.",
            "SuperClaude",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Information
        )
    }
})

[void]$window.ShowDialog()
