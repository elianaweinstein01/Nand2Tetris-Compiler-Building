path = "C:\Users\navam\OneDrive\Desktop\nand2tetris\nand2tetris\projects\08"
createFiles(path, " ")

# input: folder path and folderName (initially empty)
# output: creates ASM files with the vm code compiled
# recursive function that goes through all the folders and files found in the destination
# of the path, find the .vm files and turns them into HACK
func createFiles(folder, folderName)
	# Dir takes content of folder and formats it as (item1, item2, ... , itemn)
	# format of each item: itemi = [file/folder name, 1 if folder or 0 if file]
	contents = Dir(folder)
	vmFiles = []
	vmFileNames = []
	
	# goes through each file/folder in the location
	for item in contents
		# item is a folder - recursive call - search files in that folder
		if item[2] = 1
			createFiles(folder + "\" + item[1], item[1])
		# item is a file - file ends with .vm:
		elseif item[2] = 0 and substr(item[1], ".vm")
			# add path to file to the vmFile array
			add(vmFiles, folder + "\" + item[1])
			# add file Name to names array
			add(vmFileNames, left(item[1], len(item[1])-3))
		ok

	next
	
        # if files exist within the file array
	if len(vmFiles) != 0
		# create the .asm output file within the current folder that all files were found
		outputFile = folder + "\" + folderName + ".asm"
		# if more than 1 file found in the folder
		if len(vmFiles) > 1
			# res = sorted file array 
			res = sortFiles(vmFiles, vmFileNames)
			# res[1] = list of paths 
			vmFiles = res[1]
			# res[2] = list of corresponding names
			vmFileNames = res[2]
		ok
		# creates the actual asm file
		makeASMFile(outputFile, vmFiles, vmFileNames)
	ok

#input: (path to where file is being created, file paths, file names)
func makeASMFile(outputFile, vmFiles, fileNames)
	# f is a new file we opened in the given file path
	f = fopen(outputFile, "w")
	counter = 0
	funcCalls = 0
	# if sys file exists within the files:
	if find(fileNames, "Sys") > 0
		# BOOTSTRAPPING PROGRAM
		bootstrapping(f)
		handle_call(f, "Sys.init", 0, "Sys.init$ret.0")
	ok

	# for each file in list of files:
	for i = 1 to len(vmFiles) step 1
		# opens program file for reading
		fileVm = read(vmFiles[i])
		# turns program into a list of strings
		program = str2list(fileVm)
		# file name of current program file
		fileName = fileNames[i]
		# creates function name for function calls and labels. 
		funcName = fileName + ".None"
		# return address label
		retlabel = " "
		
		# if the line is empty or a space, then skip
		for line in program
			if line = ""
				loop
				bye
			elseif line = " "
				loop
				bye
			ok
			
			# turns line into a token 1-3 words long
	        	token = getToken(line)
	        	command = Trim(token[1])
			# creates the comment for the current command
			temp = "//"
			for elem in token	
				temp = temp + " " + elem
			next

	        	if command = "add"
				fwrite(f, temp + nl)
	            		handle_add(f)
	        	elseif command = "sub"
				fwrite(f, temp + nl)
	            		handle_sub(f)
	        	elseif command = "neg"
				fwrite(f, temp + nl)
	             		handle_neg(f)
	        	elseif command = "push"
				fwrite(f, temp + nl)
	            		handle_push(f, token[2], token[3], fileName)
	        	elseif command = "pop"
				fwrite(f, temp + nl)
	            		handle_pop(f, token[2], token[3], fileName)
			elseif command = "and" or command = "or"
				fwrite(f, temp + nl)
				handle_andor(f, command)
			elseif command = "not"
				fwrite(f, temp + nl)
				handle_not(f)
			elseif command = "eq" or command = "gt" or command = "lt"
				fwrite(f, temp + nl)
				handle_cmp(f, command, funcName, counter)
				counter = counter + 1
			# NOT A REAL COMMAND
			elseif command = "gt#"
				fwrite(f, temp + nl)
				handle_notgt(f, counter)
			# PROGRAM FLOW COMMANDS
			elseif command = "label"
				fwrite(f, temp + nl)
				handle_label(f, token[2], funcName)
			elseif command = "goto"
				fwrite(f, temp + nl)
				handle_goto(f, token[2], funcName)
			elseif command = "if-goto"
				fwrite(f, temp + nl)
				handle_ifgoto(f, token[2], funcName)
			# FUNCTION CALLING COMMANDS
			elseif command = "function"
				fwrite(f, temp + nl)
				# token[2] = function name, token[3] = amount of args
				handle_funcdecl(f, token[2], token[3])
				funcName = trim(token[2])
			elseif command = "call"
				fwrite(f, temp + nl)
				# tracks the amount of times cll has been called
 				# prevents duplicate return labels 
				funcCalls = funcCalls + 1
				funcname = trim(token[2])
				# unique label used for return address (funcName$ret.funcCalls)
				retlabel = trim(funcname) + "$ret." + funcCalls
				handle_call(f, funcname, token[3], retlabel)
			elseif command = "return"
				fwrite(f, temp + nl)
				handle_ret(f, funcName)
	        	ok
		next
	next

    fclose(f)

# BOOTSTRAPPING FUNCTION
func bootstrapping(f)
	# initializes the SP to 256 (location of the wokring stack)
	templst = ["//Bootstrap", "@256", "D=A", "@SP", "M=D", ]
	fwrite(f, list2str(templst) + nl)

func handle_add(f)
	templst = ["@SP", "A=M", "A=A-1", "D=M", "A=A-1", "D=D+M",
			"M=D", "@SP", "M=M-1", ]

	fwrite(f, list2str(templst) + nl)

func handle_sub(f)
	templst = ["@SP", "AM=M-1", "D=M", "A=A-1", "M=M-D", ]

	fwrite(f, list2str(templst) + nl)

func handle_neg(f)
	templst = ["@SP", "A=M", "A=A-1", "M=-M", ]

	fwrite(f, list2str(templst) + nl)

func handle_cmp(f, cmd, funcName, counter)
	# unconditional jump
	cond = "D;JEQ"
	# jump if greater than
	if cmd = "gt"
		cond = "D;JGT"
	# jump if less than
	elseif cmd = "lt"
		cond = "D;JLT"
	ok
	
	# labels formatted: functionName$IFTRUE(counter val)
	labelTrue = funcName + "$IFTRUE" + counter
	labelFalse = funcName + "$IFFALSE" + counter

	templist = ["@SP", "AM=M-1", "D=M", 
			"@SP", "AM=M-1", "D=M-D",
			"@" + labelTrue, cond,       
        		"@SP", "A=M", "M=0",          
        		"@" + labelFalse, "0;JMP",     
        		"(" + labelTrue + ")",       
        		"@SP", "A=M", "M=-1",         
        		"(" + labelFalse + ")",       
        		"@SP", "M=M+1", ]          

	fwrite(f, list2str(templist) + nl)

# input: (file we are writing in, token[2] (constant, local, arg, etc...), token[3] = index, filename)
# takes value from specified location and pushes it to the top of the stack

# DEFENSE: Update temp and add functionality for a new segment
func handle_push(f, s, i, fileName)
	addr = -1
	addrstr = " "
	s = trim(s)

	if s = "constant"
		addr = 0
		addrstr = "@SP"
	elseif s = "local"
		addr = 1
		addrstr = "@LCL"
	elseif s = "argument"
		addr = 2
		addrstr = "@ARG"
	elseif s = "this"
		addr = 3
		addrstr = "@THIS"
	elseif s = "that"
		addr = 4
		addrstr = "@THAT"
	elseif s = "temp"
		addr = number(i) + 5
		addrstr = "@R" + addr
	elseif s = "pointer"
		if i = 0
			addrstr = "@THIS"
		else	
			addrstr = "@THAT"
		ok
	elseif s = "static"
		addrstr = "@" + fileName + "." + i
	ok

	templst = []
	# if we are pushing from local, arg, this, or that
	if addr > 0 and addr < 5
		templst = ["@" + i, "D=A", addrstr, "A=D+M", "D=M", "@SP", 
				"A=M", "M=D", "@SP", "M=M+1", ]
	# pushing a constant onto the stack
	elseif addr = 0
		templst = ["@" + i, "D=A", addrstr, "A=M", "M=D", addrstr, "M=M+1", ]

	# pushing from static or temp
	else
		templst = [addrstr, "D=M", "@SP", "A=M", "M=D", "@SP",
				"M=M+1", ]
	ok

	fwrite(f, list2str(templst) + nl)

# input: (file we are writing in, token[2] (constant, local, arg, etc...), token[3] = index, filename)
# pops the top value of the stack and places it in specified location

# DEFENSE: Update temp and add functionality for a new segment                             
func handle_pop(f, s, i, fileName)
	addr = -1
	addrstr = " "
	s = trim(s)    

	if s = "pointer"
		addr = 0
		if i = 0
			addrstr = "@THIS"
		else
			addrstr = "@THAT"
		ok
	elseif s = "local"
		addr = 1
		addrstr = "@LCL"
	elseif s = "argument"
		addr = 2
		addrstr = "@ARG"
	elseif s = "this"
		addr = 3
		addrstr = "@THIS"
	elseif s = "that"
		addr = 4
		addrstr = "@THAT"
	elseif s = "temp"
		addr = number(i) + 5
		addrstr = "@R" + addr
	elseif s = "static"
		addr = number(i) + 16
		addrstr = "@" + fileName + "." + i
	ok

	templst = []
	# if local, arg, this, or that
	if addr != 0 and addr < 5
		templst = ["@" + i, "D=A", addrstr, "D=D+M", "@R6", "M=D",
				"@SP", "A=M", "A=A-1", "D=M", "@R6", "A=M",
				"M=D", "@SP", "M=M-1", "@R6", "M=0", ]
	# if its temp or static or SP
	else 
		templst = ["@SP", "A=M", "A=A-1", "D=M", addrstr,
				"M=D", "@SP", "M=M-1",  ]
	ok
	

	fwrite(f, list2str(templst) + nl)

#COMPARISON 
func handle_andor(f, cmd)
	op = "M=D&M"
	if cmd = "or"
		op = "M=D|M"
	ok

	templst = ["@SP", "A=M", "A=A-1", "D=M", "A=A-1", op,
			"@SP", "M=M-1", ]

	fwrite(f, list2str(templst) + nl)

func handle_not(f)
	templst = ["@SP", "A=M", "A=A-1", "M=!M", ]

	fwrite(f, list2str(templst) + nl)

# NOT REAL
func handle_notgt(f, counter)
	templst = ["@SP", "A=M", "A=A-1", "D=M", "A=A-1", "D=M-D",
			"M=0", "@IFTRUE" + counter, "D;JGT", "@SP", 
			"A=M", "A=A-1","A=A-1", "M=-1", 
			"(IFTRUE" +counter + ")", "@SP", "M=M-1", ]
	
	fwrite(f, list2str(templst) + nl)

# PROGRAM FLOW COMMANDS
func handle_label(f, labelName, funcName)
	# Creates a label (funcName.labelName)
	fullLabelName = funcName + "." + labelName 
	templst = ["(" + fullLabelName + ")"]
	fwrite(f, list2str(templst) + nl)

func handle_goto(f, labelName, funcName)
	# jumps to label @funcName.labelName
	fullLabelName = funcName + "." + labelName 
	templst = ["@" + fullLabelName, "0;JMP"]
	fwrite(f, list2str(templst) + nl)
	
func handle_ifgoto(f, labelName, funcName)
	# gets last value in stack, if its not equal to 0, jump to lable (funcName.labelName)
	fullLabelName = funcName + "." + labelName
	templst = ["@SP", "A=M", "A=A-1", "D=M", "@SP", "M=M-1",
			 "@" + fullLabelName, "D;JNE"]
	fwrite(f, list2str(templst) + nl)

# FUNCTION CALL COMMANDS
# input: (writing file, function name, number of args)
func handle_funcdecl(f, funcName, localVars)

	temp = trim(funcName)
	
        # declares the function name as a label (functionName)
	fwrite(f, "(" + temp + ")" + nl)
	
	# if there are more than 0 arguments
	if number(localVars) > 0
		# push number of local variables 0's to the top of the stack 
		for i = 1 to number(localvars)
			fwrite(f, "// pushing 0 onto the stack" + nl)
			handle_push(f, "constant", 0, funcName)
		next
	ok

#input: (writing file, function name, number of args, return label

#DEFENSE: must save current value on the stack before jumping to the called
#         function, and this will change our FRAME start off with size 6
func handle_call(f, funcname, numArgs, retlabel)
	# we add 5 to account for saved return address, LCL, ARG, THIS, and THAT, 
	# DEFENSE: change to + 6
	args = number(numArgs) + 5
	tempnum = "@" + string(args)

	# stores value in D in stack and updates stack pointer
	storeValue = "D=M" + nl + 
			"@SP" + nl + 
			"A=M" + nl + 
			"M=D" + nl + 
			"@SP" + nl + 
			"M=M+1"

	templist = ["@" + retlabel, "D=A", "@SP", "A=M", "M=D", "@SP", "M=M+1", 
			"@LCL", storeValue, 
			"@ARG", storeValue, 
			"@THIS", storeValue, 
			"@THAT", storeValue, 								
			"// (CALL) ARG = SP - 5 - n", 
		# change tempnum to be SP - 6 - n
	        	"@SP", "D=M", tempnum, "D=D-A", "@ARG", "M=D", 
			"// (CALL) LCL = SP", 
			"@SP", "D=M", "@LCL", "M=D",
			"// (CALL) Transfer control", 
			"@" + funcname, "0;JMP", "(" + retlabel + ")", ]

	fwrite(f, list2str(templist) + nl)

#DEFENSE: when we return all of the calling function's values, our frame will
#         be of length 6
func handle_ret(f, funcName)
	pop_top_val_of_LCL = "@R13" + nl + "AM=M-1" + nl + "D=M"
	
	templst = ["// (RET) FRAME = LCL", 
			"@LCL", "D=M", "@R13", "M=D", 
		"// (RET) @R14 = return address", 
		# DEFENSE: @6 because our FRAME now has length 6
			"@5", "A=D-A","D=M", "@R14","M=D", 
		"// (RET) ARG[0] = return value", 
			"@SP", "AM=M-1", "D=M", "@ARG", "A=M", "M=D", "@ARG", "D=M+1",
		"// (RET) restore SP, THAT, THIS, ARG, + LCL for caller", 
			"@SP", "M=D", 
		# DEFENSE: we'll start with the new pointer kuku
			pop_top_val_of_LCL, "@THAT", "M=D", 
			pop_top_val_of_LCL, "@THIS", "M=D", 
			pop_top_val_of_LCL, "@ARG", "M=D", 
			pop_top_val_of_LCL, "@LCL", "M=D", 
		"// (RET) return",
		"@R14", "A=M", "0;JMP", ]
	
	fwrite(f, list2str(templst) + nl)
	
	// if the function is the get function
	if substr(funcName, "get") > 0
		// set @R5 to be the return value
	# DEFENSE: set it to @R6
		temp = ["// (RET) get function", "@SP", "AM=M-1", "D=M", "@R5", "M=D", ]
		fwrite(f, list2str(temp) + nl)
	ok


#--------------------------------------------
#--------------Helper Functions--------------
#--------------------------------------------

# input: a program line
# output: command 1-3 words long. token[1], token[2] and token[3]
func getToken(line)
	# creates a copy of line input
	temp = copy(line, 1)
	# trim removes leading and trailing whitespace
	temp = trim(temp)
	# remove tab (elianas computer has this glitch) 
	if temp[1] = "	"
		temp = right(temp, len(temp)-1) 
	ok
	# finds location of a comment	
	commentpos = substr(temp, "/")
	# if there is a comment in the line
	if commentpos != 0
		# remove the comment
		temp = trim(left(temp, commentpos-1))
	ok
	# initialized token array which will be returned
	token = []
	# get position of next whitespace
	cmdPos = substr(temp, " ")
	# if there is no whitespace
	if cmdPos = 0
		# command is one word, entire temp gets added to command
		add(token, temp)
	# if a whitespace does exist
	else
		# extract first word and add it to token array
		cmd = substr(temp, 1, cmdPos - 1)
		token = [cmd]
		# cut temp to start from second word
		temp = trim(substr(temp, cmdPos+1))
		
		# extracts the last 1-2 words in the commands
		x = 0
		while len(temp) > 0 and x < 3 and temp != " "
			# finds the next space
			pos = substr(temp, " ")
			tmp = substr(temp, 1, pos)
			# if no space, command is two words
			if pos = 0
				add(token, temp)
				exit
			ok
			# if space, add 2nd word and check third word
			add(token, tmp)
			temp = trim(substr(temp, pos+1))
			x += 1
		end
	ok
	
	return token
		

func getFolderName(path)
	temp = copy(path, 1)
	x = 0
	while x<10 
		x += 1
		pos = substr(temp, "\")
		if pos = 0
			return temp
			x = 10
			bye
		ok
		temp = substr(temp, pos+1)
	end

# input: all the file paths, all the file names	
# output: sorted files with sys (if exists) being first and main (if exists) next, 
#         and then the rest of the files following. 
func sortFiles(files, names)
	# initializes a 2d array
	sorted = [[], []]
	# gets the index of function called sys
	index = find(names, "Sys")
	# if sys exists within the files list, add path to sorted[1] and names to sorted[2]
	if index > 0 
		add(sorted[1], files[index])
		add(sorted[2], names[index]) 
	ok
	
        # gets the index of the main function
	index = find(names, "Main")
	# same as with sys
	if index > 0 
		add(sorted[1], files[index])
		add(sorted[2], names[index]) 
	ok

	# go through the rest of the files
	for i = 1 to len(files) step 1
		# if the file is not already in the list
		# (if file is not main, sys) - add to list
		if find(sorted[1], files[i]) = 0
			add(sorted[1], files[i])
			add(sorted[2], names[i])
		ok
	next 	
	return sorted
		
		


