# Build poppler library for windows PowerShell Script
# Created by SKPark / Dec 20, 2022
[System.Environment]::SetEnvironmentVariable('SOURCEDIR','.\')
[System.Environment]::SetEnvironmentVariable('CRAFTMASTERDIR','CraftMaster\')

# TARGET Select
# windows-msvc2019_64-cl - Microsoft Visual Studio 2019
# windows-mingw_64-gcc - MingW
[System.Environment]::SetEnvironmentVariable('TARGET','windows-msvc2019_64-cl')

$curpopplerdir = [System.Environment]::CurrentDirectory+"\poppler-mirror"
[System.Environment]::SetEnvironmentVariable('POPPLER_FOLDER',$curpopplerdir)

function craft() {
    python $env:SOURCEDIR$env:CRAFTMASTERDIR"CraftMaster.py" --config "$env:POPPLER_FOLDER\appveyor.ini" --variables "APPVEYOR_BUILD_FOLDER=$env:POPPLER_FOLDER" --target $env:TARGET -c $args
    if($LASTEXITCODE -ne 0) { 
        Write-Output $LASTEXITCODE 
        return $LASTEXITCODE
    }
}

function main() {
    git clone -q --depth=1 https://invent.kde.org/packaging/craftmaster.git $env:SOURCEDIR$env:CRAFTMASTERDIR 
    git clone https://gitlab.freedesktop.org/poppler/test.git $env:POPPLER_FOLDER/../test
    
    git clone -q --depth=1 --branch=master https://github.com/tsdgeos/poppler_mirror.git $env:POPPLER_FOLDER
    Set-Location $env:POPPLER_FOLDER
    git checkout -qf 6fd09e134fe059bee6282dc42729d971ee8da43b
    Set-Location ..
    
    craft craft
    craft --install-deps poppler
    craft --no-cache --src-dir "$env:POPPLER_FOLDER" poppler
    craft --no-cache --src-dir "$env:POPPLER_FOLDER" --package poppler
    craft --src-dir "$env:POPPLER_FOLDER" --test poppler
}

main
Write-Output $LASTEXITCODE 