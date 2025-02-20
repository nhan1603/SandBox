# SandBox

- Copy the `SandBox.exe` into the Window Sandbox

- To manually start the sand box, run the command `start sandbox.wsb`

- To automatically create and run the script, do `.\Execute2.ps1 -file "C:\Users\920322\Workspace\SandBox\SandBox.exe" -output "output.txt" -NoNetwork -ReadOnly -timeout 20`

- Finest working version is `.\Execute2.ps1 -file "C:\Users\920322\Workspace\SandBox\WindowSandbox\SandBox.exe" -output "output2.txt" -NoNetwork -timeout 20`

- might need additional setup ` Set-ExecutionPolicy RemoteSigned`
