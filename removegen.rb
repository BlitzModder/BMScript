require 'rubygems'
require 'rbconfig'
require 'fileutils'
require 'archive/zip'

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

os, bit = getOSType()

if !File.exist?("Data")
    puts "'Data' directory does NOT exist in the current directory."
    exit
end

installDir = "../install"
if os == "windows"
    installDir = "..\\install"
end
if !File.exist?(installDir)
    puts "'install' directory does NOT exist in the current directory."
    exit
end

puts "This script generates remove directory from Data directory and install directory."

if os == "windows"
    if File.exist?("..\\remove")
        FileUtils.rm_rf("..\\remove")
        Dir.mkdir("..\\remove")
    end
    puts "Cleared remove directory."

    zipArray = Dir.glob("..\\install\\**\\*.zip")
    for installZipPath in zipArray do
        puts "Processing " + installZipPath.gsub("\.\.\\\\install\\\\", "") + " ..."
        Archive::Zip.extract(installZipPath, "..\\install")
        fileArray = Dir.glob("..\\install\\Data\\**\\*")
        for installFile in fileArray do
            if File::ftype(installFile) != "directory"
                dataFile = installFile.gsub("\.\.\\\\install\\\\", "")
                removeFile = installFile.gsub("\.\.\\\\install\\\\", "\.\.\\\\remove\\\\")
                removeFileArray = removeFile.split('\\')
                removeFileDir = (removeFileArray.first removeFileArray.size - 1).join("\\")
                if !File.exist?(removeFileDir)
                    FileUtils.mkdir_p(removeFileDir)
                end
                if File.exist?(dataFile)
                    FileUtils.copy(dataFile, removeFile)
                end
            end
        end
        FileUtils.rm_rf("..\\install\\Data")
        removeZipPath = installZipPath.gsub("\.\.\\\\install\\\\", "\.\.\\\\remove\\\\")
        Archive::Zip.archive(removeZipPath, "..\\remove\\Data")
        FileUtils.rm_rf("..\\remove\\Data")
    end
    puts "Completed generating remove directory."
else
    if File.exist?("../remove")
        FileUtils.rm_rf("../remove")
        Dir.mkdir("../remove")
    end
    puts "Cleared remove directory."

    zipArray = Dir.glob("../install/**/*.zip")
    for installZipPath in zipArray do
        puts "Processing " + installZipPath.gsub("\.\./install/", "") + " ..."
        Archive::Zip.extract(installZipPath, "../install")
        fileArray = Dir.glob("../install/Data/**/*")
        for installFile in fileArray do
            if File::ftype(installFile) != "directory"
                dataFile = installFile.gsub("\.\./install/", "")
                removeFile = installFile.gsub("\.\./install/", "\.\./remove/")
                removeFileArray = removeFile.split('/')
                removeFileDir = (removeFileArray.first removeFileArray.size - 1).join("/")
                if !File.exist?(removeFileDir)
                    FileUtils.mkdir_p(removeFileDir)
                end
                if File.exist?(dataFile)
                    FileUtils.copy(dataFile, removeFile)
                end
            end
        end
        FileUtils.rm_rf("../install/Data")
        removeZipPath = installZipPath.gsub("\.\./install/", "\.\./remove/")
        Archive::Zip.archive(removeZipPath, "../remove/Data")
        FileUtils.rm_rf("../remove/Data")
    end
    puts "Completed generating remove directory."
end
