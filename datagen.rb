require 'rbconfig'
require 'fileutils'

def getOSType
    os = "unknown"
    bit = 64
    case RbConfig::CONFIG['host_os']
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        os = "windows"
        if `echo %PROCESSOR_ARCHITECTURE%` == "x86"
            bit = 32
        end
    when /darwin|mac os/
        os = "mac"
        if `uname -a | grep i386` != ""
            bit = 32
        end
    when /linux|solaris|bsd/
        os = "linux"
        if `uname -a | grep i686` != "" || `uname -a | grep i386` != ""
            bit = 32
        end
    end
    return os,bit
end

if !File.exist?("Data")
    puts "'Data' directory does NOT exist in the current directory."
    exit
end

if !File.exist?("default.tex")
    puts "default.tex does NOT exist in the current directory."
    exit
end

os, bit = getOSType()
toolPath = ""
pvrPath = []
if os == "windows" && bit == 64
    toolPath = "PVRTexTool\\Windows_x86_64\\PVRTexTool.exe"
    pvrArray = Dir.glob("Data\\**\\*.PowerVR_iOS.pvr")
elsif os == "windows" && bit == 32
    toolPath = "PVRTexTool\\Windows_x86_32\\PVRTexTool.exe"
    pvrArray = Dir.glob("Data\\**\\*.PowerVR_iOS.pvr")
elsif os == "mac"
    toolPath = "PVRTexTool/OSX_x86/PVRTexTool"
    pvrArray = Dir.glob("Data/**/*.PowerVR_iOS.pvr")
elsif os == "linux" && bit == 64
    toolPath = "PVRTexTool/Linux_x86_64/PVRTexTool"
    pvrArray = Dir.glob("Data/**/*.PowerVR_iOS.pvr")
elsif os == "linux" && bit == 32
    toolPath = "PVRTexTool/Linux_x86_32/PVRTexTool"
    pvrArray = Dir.glob("Data/**/*.PowerVR_iOS.pvr")
end

if !File.exist?(toolPath)
    puts "Appropriate PVRTexTool does NOT exist in the current directory."
    exit
end

puts "This script converts all iOS_PowerVR.pvr files into mali.pvr in the Data directory."
puts "Which mali format do you want to convert into? (1.RGBA4444  2.RGBA8888) [Default:1]"
format = gets.to_s
if format != "1" && format != "2"
    format = "1"
end

failArray = []
for pvrPath in pvrArray do
    maliPath = pvrPath.gsub("\.PowerVR_iOS\.pvr", "\.mali\.pvr")
    texPath = pvrPath.gsub("\.PowerVR_iOS\.pvr","\.tex")
    if format == "1"
        result = system(toolPath + " -i " + pvrPath + " -o " + maliPath + " -f r4g4b4a4,UBN,lRGB")
        if !result
            failArray += pvrPath
        end
    elsif format == "2"
        result = system(toolPath + " -i " + pvrPath + " -o " + maliPath + " -f r8g8b8a8,UBN,lRGB")
        if !result
            failArray += pvrPath
        end
    end
    File.delete(pvrPath)
    FileUtils.copy("default.tex", texPath)
end

if failArray.count > 0
    puts "Following file(s) could not be converted:"
    puts failArray
end
