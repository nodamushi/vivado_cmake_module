set env_file      [lindex $argv 0]
source $env_file

setws $ws
app build -name $prj
