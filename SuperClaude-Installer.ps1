# SuperClaude Installer - Windows
# Lancer via Installer.bat

try {

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.ComponentModel

$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="SuperClaude Installer"
    Width="480" Height="440"
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

        <TextBlock Grid.Row="0"
            Text="** SuperClaude"
            Foreground="White"
            FontSize="26"
            FontWeight="Bold"
            FontFamily="Segoe UI"
            HorizontalAlignment="Center"
            Margin="0,0,0,4"/>

        <TextBlock Grid.Row="1"
            Text="Config Claude Code - skills, MCPs, memoire Obsidian"
            Foreground="#8888aa"
            FontSize="12"
            FontFamily="Segoe UI"
            HorizontalAlignment="Center"
            Margin="0,0,0,16"/>

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

        <ProgressBar Grid.Row="3"
            Name="ProgressBar"
            Height="8"
            Minimum="0"
            Maximum="9"
            Value="0"
            Foreground="#7c3aed"
            Background="#2a2a4a"
            Margin="0,0,0,8"/>

        <TextBlock Grid.Row="4"
            Name="StatusLabel"
            Text="Pret a installer"
            Foreground="#8888aa"
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
                                    <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#6d28d9"/>
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
                                    <Border Background="{TemplateBinding Background}" CornerRadius="6" Padding="{TemplateBinding Padding}">
                                        <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsMouseOver" Value="True">
                                            <Setter Property="Background" Value="#047857"/>
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
$openButton    = $window.FindName('OpenClaudeButton')
$logScroll     = $window.FindName('LogScroll')

# Steps: label + command
$steps = @(
    @{ Label = "Verification Node.js...";      Cmd = { node --version 2>&1 } }
    @{ Label = "Verification Claude Code...";  Cmd = { claude --version 2>&1 } }
    @{ Label = "Plugin code-review...";        Cmd = { claude plugin install code-review 2>&1 } }
    @{ Label = "Plugin superpowers...";        Cmd = { claude plugin install superpowers 2>&1 } }
    @{ Label = "Plugin impeccable...";         Cmd = { claude plugin install impeccable 2>&1 } }
    @{ Label = "Plugin taste-skill...";        Cmd = { claude plugin install taste-skill 2>&1 } }
    @{ Label = "Plugin playwright...";         Cmd = { claude plugin install playwright 2>&1 } }
    @{ Label = "MCP context7...";             Cmd = { claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp 2>&1 } }
    @{ Label = "MCP playwright...";           Cmd = { claude mcp add playwright --scope user -- npx @playwright/mcp@latest 2>&1 } }
)

$worker = [System.ComponentModel.BackgroundWorker]::new()
$worker.WorkerReportsProgress = $true

$worker.add_DoWork({
    param($sender, $e)
    $allSteps = $e.Argument
    for ($i = 0; $i -lt $allSteps.Count; $i++) {
        $step = $allSteps[$i]
        $sender.ReportProgress($i, $step.Label)
        try {
            $out = & $step.Cmd
            $sender.ReportProgress($i, "[OK] $($step.Label) -- $out")
        } catch {
            $sender.ReportProgress($i, "[WARN] $($step.Label): $_")
        }
        Start-Sleep -Milliseconds 400
    }
})

$worker.add_ProgressChanged({
    param($sender, $e)
    $msg = $e.UserState
    $ts  = Get-Date -Format "HH:mm:ss"
    $logBox.Text += "[$ts] $msg`n"
    $logScroll.ScrollToEnd()
    $progressBar.Value = $e.ProgressPercentage
    $statusLabel.Text  = $msg
})

$worker.add_RunWorkerCompleted({
    param($sender, $e)
    if ($e.Error) {
        $logBox.Text  += "[ERREUR] $($e.Error.Message)`n"
        $statusLabel.Text = "Erreur - voir log"
    } else {
        $logBox.Text  += "`n[OK] Installation terminee !`n"
        $statusLabel.Text = "Installation terminee !"
        $progressBar.Value = 9
        $openButton.Visibility = [System.Windows.Visibility]::Visible
    }
    $installButton.IsEnabled = $true
})

$installButton.Add_Click({
    $installButton.IsEnabled = $false
    $logBox.Text = ""
    $worker.RunWorkerAsync($steps)
})

$openButton.Add_Click({
    try { Start-Process "claude" }
    catch {
        [System.Windows.MessageBox]::Show(
            "Tape 'claude' dans un terminal pour demarrer.",
            "SuperClaude",
            [System.Windows.MessageBoxButton]::OK
        )
    }
})

[void]$window.ShowDialog()

} catch {
    Write-Host ""
    Write-Host "ERREUR: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Details: $($_.ScriptStackTrace)"
    Write-Host ""
    pause
}
