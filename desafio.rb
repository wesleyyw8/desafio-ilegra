require 'listen'
require 'mysql2'
$client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "1234", :database => "desafioFrontend")

#Amount of clients in the input file:
#Amount of salesman in the input file
#ID of the most expensive sale
#Worst salesman ever
def writeResult
	finalAmountClients = ""
	finalAmountSalesman = ""
	finalIdMostExpensiveSale = ""
	finalWorstSalesManEver = ""

	result = $client.query("SELECT count(*) as total from Customer")
	result.each do |row|
		temp = row["total"]
		finalAmountClients = "Amount of clients in the input file: #{temp}"
	end

	result = $client.query("SELECT count(*) as total from Salesman")
	result.each do |row|
		temp = row["total"]
		finalAmountSalesman = "Amount of salesman in the input file: #{temp}" 
	end

	result = $client.query("select id from Sales order by total DESC LIMIT 1")
	result.each do |row|
		temp = row["id"]
		finalIdMostExpensiveSale = "ID of the most expensive sale: #{temp}" 
	end
	worstListNames = ""
	worstSalesMan = $client.query("select S.Name from Salesman S left join Sales SA on S.Name = SA.name_salesman WHERE SA.name_salesman is null")
	if worstSalesMan.size > 0
		worstSalesMan.each do |row|
			worstListNames += row["Name"]+" "
		end
	finalWorstSalesManEver "didnt sell anything: #{worstListNames}"
	else
		result  = $client.query("select name_salesman, sum(total) as total from Sales group by(name_salesman) ORDER BY total LIMIT 1")
		result.each do |row|
			nameSalesMan = row["name_salesman"]
			total = row["total"]
			finalWorstSalesManEver = "Worst salesman ever #{nameSalesMan} his total is #{total}"
		end
	end
	File.write('/home/wesleylinux/data/out/analysys.done.dat', finalAmountClients + "\n" +finalAmountSalesman + "\n" + finalIdMostExpensiveSale + "\n" + finalWorstSalesManEver)	
	puts("analysys.done.dat created")
end

def calculatesTotalSalesItem(param)
	result = 0;
	param.split(",").each do |items|
		item = items.split("-")
		result += (item[1].to_f*item[2].to_f)
	end
	return result;
end

def analyseFile(fileName)
	File.open(fileName, "r") do |f|
	  f.each_line do |line|
	  	lineArr = line.split('ç');
    	if lineArr[0] == "001"
    		insertInto("Salesman", lineArr)
    	elsif lineArr[0] == "002"
    		insertInto("Customer", lineArr)
    	elsif lineArr[0] == "003"
    		lineArr[2] = calculatesTotalSalesItem(lineArr[2])
    		insertInto("Sales", lineArr)
    	end    		
	  end
	end
end

def processFiles(files)
	if files.respond_to?("each")
		files.each do |name|
		    analyseFile(name)
		end
	end
	writeResult()
end

def insertInto(tableName, lineArr)
	if tableName == "Salesman"
		$client.query("INSERT INTO #{tableName} (CPF, Name, Salary)  VALUES (#{lineArr[1]}, '#{lineArr[2]}', #{lineArr[3]} ) ON DUPLICATE KEY UPDATE CPF=CPF, Name=Name, Salary=Salary")
	elsif tableName == "Customer"
		$client.query("INSERT INTO #{tableName} (CNPJ, Name, BusinessArea)  VALUES (#{lineArr[1]}, '#{lineArr[2]}', '#{lineArr[3]}' ) ON DUPLICATE KEY UPDATE CNPJ=CNPJ, Name=Name, BusinessArea=BusinessArea")
	elsif tableName == "Sales"
		$client.query("INSERT INTO #{tableName} (name_salesman, total)  VALUES ('#{lineArr[3].strip!}', #{lineArr[2]})")
		#puts("#{lineArr[3].strip!}")
	end
	#client.query("SELECT * FROM users WHERE group='#{escaped}'")
end

listener = Listen.to('/home/wesleylinux/data/in',  only: /\.dat$/) do |modified, added, removed|
  	if modified.size > 0 or added.size > 0 or removed.size > 0 or added.size > 1 	
	  	$client.query("CALL deleteAllData()")
	  	puts("------------------------- ANALYSIS -------------------")
	  	
	  	files = Dir["/home/wesleylinux/data/in/*.dat"]
	    processFiles files
  	end
end
listener.start
sleep