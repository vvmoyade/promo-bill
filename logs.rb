require 'pry'
module Log
	attr_accessor :logs	
	class << self
		def get_logs
		@logs=""		
		puts "Enter number of logs"
		n= gets.to_i
		while n>0
			begin
				puts "Iteration #{n}"
				puts "enter duration in hh:mm:ss"	
				duration = gets.chomp
				# raise exception if regex doesn't match
				raise unless duration.match('^(?:(?:([01]?\d|2[0-3]):)?([0-5]?\d):)?([0-5]?\d)$')
					puts "enter number in format nnn-nnn-nnn with no leading zeros"
					number= gets.chomp
					raise unless number.match('^[1-9][0-9]{2}-[0-9]{3}-[0-9]{3}$')
					if @logs.include? number
						@logs = Log.replace_logs(@logs,duration,number) 
					else	
						# Logs in string format
						@logs << duration+","+number+"\n"
					end
					n= n-1
			rescue
				puts "Invalid format.Please try again"
				retry
	  	end
 		end
		@logs
	end
	def replace_logs(logs,duration,number)
		# Add shared duration and replacing already existing log
		sub_str=""
		logs.split("\n").each do |str|
					sub_str= str if logs.include? number
		end
		sub_h,sub_m,sub_s = sub_str.split(",").first.split(':').map(&:to_i)
		duration_h,duration_m,duration_s = duration.split(':').map(&:to_i)
		sec= ((sub_s+duration_s)+(sub_m+duration_m)*60+(sub_h+duration_h)*3600)
		replace_string = "#{[sec / 3600, (sec / 60) % 60, sec % 60].map { |t| t.to_s.rjust(2,'0') }.join(':')}"+","+"#{number}"
		logs.gsub!(sub_str,replace_string)
		logs
	end
	end	
end

class Billing
	attr_accessor :duration,:number,:amount,:shared_time
	
	def initialize(duration,number)
		@duration=duration
		@number= number
	end
	
	def calculate_bill
		time= duration.split(":").map(&:to_i)
		duration_in_seconds= time.first*3600+time[1]*60+time.last
		if duration_in_seconds < 300 # 5 mins
			# 3 cents for seconds
			self.amount = duration_in_seconds*3
			self.shared_time= duration_in_seconds
		else
			#150 cents at start of minute
			self.shared_time= duration_in_seconds
			start_of_minute = ((time.last >0)? time[1]+1 : time[1])
			self.amount = start_of_minute*150			
		end
	end
	
end

class Phone< Billing 
	attr_accessor :logs

	def initialize(logs_summary)
		@logs=[]
		logs_summary.split("\n").each_with_index do|summary,index|
			# creating bill array
			@logs[index]=Billing.new(summary.split(",").first,summary.split(",").last)			
		end	

		@logs.each do |log|
			log.calculate_bill
		end
	end

	def sort_logs_get_highest_amount
		#Sort in descending order of amount
		log= self.logs.sort{|a,b| b.amount <=> a.amount}
		log.first.amount
	end
end

logs = Log.get_logs
phone_billing = Phone.new(logs)
amount = phone_billing.sort_logs_get_highest_amount
puts "Your promotional amount is #{amount} cents"



