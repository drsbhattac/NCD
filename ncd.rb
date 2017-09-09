#!/usr/bin/ruby
require 'fileutils'
# Normalised compression distance calculation 
# Author: Sukriti Bhattacharya

class NCD

	#create a temporary directory for the concatenated files

	def createT
		concat = Dir.pwd+"/t1"
		zip = Dir.pwd+"/t2"
		
		# Create '/t1' and '/t2' if not exists
		unless File.directory?(concat)
    		FileUtils.mkdir_p(concat)
		end
		
		unless File.directory?(zip)
    		FileUtils.mkdir_p(zip)
		end
		
	return concat, zip 
	end


	#compress folder contents

	def compressF(f1)
		Dir.foreach("#{f1}") do |x|
		next if x == '.' or x == '..' or x.start_with?('.')
	 		system("7za a -t7z t2/#{f1}#{x}.7z #{f1}/#{x}")
	 		#system("7za a -t7z -mx9 -mmt2 -ms4g -m0=lzma:d128m:fb256 t2/#{f1}#{x}.7z #{f1}/#{x}") 
		end
	end
	
	#compress the concatenated files

	def concatinate(f1, f2)
		Dir.foreach("#{f1}") do |x0|
			next if x0 == '.' or x0 == '..' or x0.start_with?('.')
			Dir.foreach("#{f2}") do |x1|
				next if x1 == '.' or x1 == '..' or x1.start_with?('.')
				
				# concatenate x and y  		
 				system("cat #{f1}/#{x0} #{f2}/#{x1} > t1/#{x0}#{x1}")
				# compress concatenated files
 				system("7za a -t7z t2/#{x0}#{x1}.7z  t1/#{x0}#{x1}")
 	    		#system("7za a -t7z -mx9 -mmt2 -ms4g -m0=lzma:d128m:fb256 t2/#{x0}#{x1}.7z t1/#{x0}#{x1}kd")
 	    		
 	    	end 
 	    end		
	end
	
	#calculate NCD between the files stored in folder1 and folder2 respectively

	def calculateNCD(f1,f2)
		outputFile = File.new("ncd.csv", "w") 
		Dir.foreach("#{f2}") do |x0|
			next if x0 == '.' or x0 == '..' or x0.start_with?('.')
			outputFile.write ",#{x0}"
		end
		outputFile.write "\n"

		Dir.foreach("#{f1}") do |x0|
			next if x0 == '.' or x0 == '..' or x0.start_with?('.')
			outputFile.write"#{x0}"
			cx = File.size("t2/#{f1}#{x0}.7z").to_f
    		Dir.foreach("#{f2}") do |x1|
				next if x1 == '.' or x1 == '..' or x1.start_with?('.')
 	    		cy = File.size("t2/#{f2}#{x1}.7z").to_f
 				cxy = File.size("t2/#{x0}#{x1}.7z").to_f 	
	    
				#calculate NCD
	    		ncd = (cxy - [cx,cy].min) / [cx,cy].max
				
				# write the result to the output file	    
	    		outputFile.write ",#{ncd}" 		    
 			end 	
 			outputFile.write"\n" 
 		end	

		outputFile.close()
	end
	
	#delete tempory folder and runtime generated files

	def deleteT(dir1, dir2)
		FileUtils.rm_rf Dir.glob("#{dir1}*")
		FileUtils.rm_rf Dir.glob("#{dir2}*")
	end
end

#nain()

startT = Time.new
trace = NCD.new
temp1, temp2 = trace.createT

threads = []
threads << Thread.new{trace.compressF("#{ARGV[0]}")}
threads << Thread.new{trace.compressF("#{ARGV[1]}")}
threads << Thread.new{trace.concatinate("#{ARGV[0]}","#{ARGV[1]}")}


threads.each {|thread| thread.join}

trace.calculateNCD("#{ARGV[0]}","#{ARGV[1]}")
trace.deleteT(temp1, temp2)

endT = Time.new
puts "#{startT}"
puts "#{endT}"