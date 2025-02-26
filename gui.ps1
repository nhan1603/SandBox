Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Sandbox Execution Tool'
$form.Size = New-Object System.Drawing.Size(600,400)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

# File Selection Group
$fileGroup = New-Object System.Windows.Forms.GroupBox
$fileGroup.Location = New-Object System.Drawing.Point(20,20)
$fileGroup.Size = New-Object System.Drawing.Size(540,100)
$fileGroup.Text = "Executable Selection"
$form.Controls.Add($fileGroup)

# Executable File TextBox
$fileTextBox = New-Object System.Windows.Forms.TextBox
$fileTextBox.Location = New-Object System.Drawing.Point(10,30)
$fileTextBox.Size = New-Object System.Drawing.Size(400,20)
$fileTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$fileGroup.Controls.Add($fileTextBox)

# Browse Button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(420,29)
$browseButton.Size = New-Object System.Drawing.Size(100,23)
$browseButton.Text = "Browse"
$browseButton.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Executable files (*.exe)|*.exe|All files (*.*)|*.*"
    if ($openFileDialog.ShowDialog() -eq 'OK') {
        $fileTextBox.Text = $openFileDialog.FileName
    }
})
$fileGroup.Controls.Add($browseButton)

# Output Settings Group
$outputGroup = New-Object System.Windows.Forms.GroupBox
$outputGroup.Location = New-Object System.Drawing.Point(20,130)
$outputGroup.Size = New-Object System.Drawing.Size(540,120)
$outputGroup.Text = "Output Settings"
$form.Controls.Add($outputGroup)

# Output File Label
$outputLabel = New-Object System.Windows.Forms.Label
$outputLabel.Location = New-Object System.Drawing.Point(10,30)
$outputLabel.Size = New-Object System.Drawing.Size(100,20)
$outputLabel.Text = "Output File Name:"
$outputGroup.Controls.Add($outputLabel)

# Output File TextBox
$outputTextBox = New-Object System.Windows.Forms.TextBox
$outputTextBox.Location = New-Object System.Drawing.Point(110,30)
$outputTextBox.Size = New-Object System.Drawing.Size(410,20)
$outputTextBox.Text = "output.txt"
$outputGroup.Controls.Add($outputTextBox)

# Host Folder Label
$folderLabel = New-Object System.Windows.Forms.Label
$folderLabel.Location = New-Object System.Drawing.Point(10,70)
$folderLabel.Size = New-Object System.Drawing.Size(100,20)
$folderLabel.Text = "Host Folder:"
$outputGroup.Controls.Add($folderLabel)

# Host Folder TextBox
$folderTextBox = New-Object System.Windows.Forms.TextBox
$folderTextBox.Location = New-Object System.Drawing.Point(110,70)
$folderTextBox.Size = New-Object System.Drawing.Size(310,20)
$folderTextBox.Text = "C:\Users\"
$outputGroup.Controls.Add($folderTextBox)

# Browse Folder Button
$browseFolderButton = New-Object System.Windows.Forms.Button
$browseFolderButton.Location = New-Object System.Drawing.Point(430,69)
$browseFolderButton.Size = New-Object System.Drawing.Size(90,23)
$browseFolderButton.Text = "Browse"
$browseFolderButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq 'OK') {
        $folderTextBox.Text = $folderBrowser.SelectedPath
    }
})
$outputGroup.Controls.Add($browseFolderButton)

# Options Group
$optionsGroup = New-Object System.Windows.Forms.GroupBox
$optionsGroup.Location = New-Object System.Drawing.Point(20,260)
$optionsGroup.Size = New-Object System.Drawing.Size(540,60)
$optionsGroup.Text = "Execution Options"
$form.Controls.Add($optionsGroup)

# Network Checkbox
$networkCheckBox = New-Object System.Windows.Forms.CheckBox
$networkCheckBox.Location = New-Object System.Drawing.Point(10,25)
$networkCheckBox.Size = New-Object System.Drawing.Size(150,20)
$networkCheckBox.Text = "Disable Network"
$optionsGroup.Controls.Add($networkCheckBox)

# Read Only Checkbox
$readOnlyCheckBox = New-Object System.Windows.Forms.CheckBox
$readOnlyCheckBox.Location = New-Object System.Drawing.Point(170,25)
$readOnlyCheckBox.Size = New-Object System.Drawing.Size(150,20)
$readOnlyCheckBox.Text = "Read Only"
$optionsGroup.Controls.Add($readOnlyCheckBox)

# Timeout Label and TextBox
$timeoutLabel = New-Object System.Windows.Forms.Label
$timeoutLabel.Location = New-Object System.Drawing.Point(330,25)
$timeoutLabel.Size = New-Object System.Drawing.Size(100,20)
$timeoutLabel.Text = "Timeout (sec):"
$optionsGroup.Controls.Add($timeoutLabel)

$timeoutTextBox = New-Object System.Windows.Forms.TextBox
$timeoutTextBox.Location = New-Object System.Drawing.Point(430,25)
$timeoutTextBox.Size = New-Object System.Drawing.Size(90,20)
$timeoutTextBox.Text = "20"
$optionsGroup.Controls.Add($timeoutTextBox)

# Execute Button
$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(200,330)
$executeButton.Size = New-Object System.Drawing.Size(180,30)
$executeButton.Text = "Execute in Sandbox"
$executeButton.BackColor = [System.Drawing.Color]::FromArgb(0,120,212)
$executeButton.ForeColor = [System.Drawing.Color]::White
$executeButton.FlatStyle = 'Flat'
$form.Controls.Add($executeButton)

# Add hover effects for execute button
$executeButton.Add_MouseEnter({
    $this.BackColor = [System.Drawing.Color]::FromArgb(0,100,180)
})
$executeButton.Add_MouseLeave({
    $this.BackColor = [System.Drawing.Color]::FromArgb(0,120,212)
})

# Execute Button Click Event
$executeButton.Add_Click({
    # Validate inputs
    if (-not $fileTextBox.Text) {
        [System.Windows.Forms.MessageBox]::Show("Please select an executable file.", "Validation Error")
        return
    }
    if (-not $outputTextBox.Text) {
        [System.Windows.Forms.MessageBox]::Show("Please specify an output file name.", "Validation Error")
        return
    }
    if (-not $folderTextBox.Text) {
        [System.Windows.Forms.MessageBox]::Show("Please specify a host folder.", "Validation Error")
        return
    }

    if (-not (Test-Path $folderTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("The specified host folder does not exist.", "Validation Error")
        return
    }

    if (-not (Test-Path $fileTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("The specified executable does not exist.", "Validation Error")
        return
    }

    $fileName = Split-Path -Path $fileTextBox.Text -Leaf

    if ($fileName -ceq "Execute.ps1" -or $fileName -ceq "gui.ps1") {
        [System.Windows.Forms.MessageBox]::Show("Nah bro, don't do this.", "Validation Error")
        return
    }

    # Build the parameter string
    $params = @{
        file = $fileTextBox.Text
        output = $outputTextBox.Text
        hostFolder = $folderTextBox.Text
        NoNetwork = $networkCheckBox.Checked
        ReadOnly = $readOnlyCheckBox.Checked
        timeout = [int]$timeoutTextBox.Text
    }

    # Hide the form while executing
    $form.Hide()

    try {
        # Execute the sandbox script with parameters
        & ".\Execute.ps1" @params

        [System.Windows.Forms.MessageBox]::Show("Execution completed successfully!", "Success")
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error during execution: $_", "Error")
    }
    finally {
        # Close the form
        $form.Close()
    }
})

# Show the form
$form.ShowDialog()