local UnixExitCodes = {
   [0] =  "The operation completed successfully.",
   [1] =  "Catchall for general errors",
   [2] =  "Misuse of shell builtins (according to Bash documentation)",
   [126] =  "Command invoked cannot execute",
   [127] =  "“command not found”",
   [128] =  "Invalid argument to exit",
   [130] =  "Script terminated by Control-C"
}

return UnixExitCodes