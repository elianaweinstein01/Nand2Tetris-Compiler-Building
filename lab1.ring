path = "C:\Users\navam\Downloads\nand2tetris1\nand2tetris\projects\7"
pathfordefense = "C:\Users\navam\Downloads\gtpStackTest"
#createFiles(path)
createFiles(pathfordefense)

func createFiles(folder)
	contents = Dir(folder)
	
	for item in contents
		if item[2] = 1
			createFiles(folder + "\" + item[1])
		elseif item[2] = 0 and substr(item[1], ".vm")
			makeASMFile(folder + "\" + item[1], item[1])
		ok
	next


# process each .vm file

func makeASMFile(p, fileName)
	outputFileName = substr(copy(p, 1), ".vm", ".asm")
	f = fopen(outputFileName, "w")
	fileVm = read(p)
	program = str2list(fileVm)
	counter = 0

	for line in program
		if line = ""
			loop
			bye
		elseif line = " "
			loop
			bye
		ok

        	token = getToken(line)
	
        	command = token[1]

        	if command = "add"
            		handle_add(f)
        	elseif command = "sub"
            		handle_sub(f)
        	elseif command = "neg"
             		handle_neg(f)
        	elseif command = "push"
            		handle_push(f, token[2], token[3], fileName)
        	elseif command = "pop"
            		handle_pop(f, token[2], token[3], fileName)
		elseif command = "and" or command = "or"
			handle_andor(f, command)
		elseif command = "not"
			handle_not(f)
		elseif command = "eq" or command = "gt" or command = "lt"
			handle_cmp(f, command, counter)
            		counter = counter + 1
		elseif command = "gt#"
			handle_notgt(f, counter)
        	ok
	next

    fclose(f)
 

func handle_add(f)
	templst = ["@SP", "A=M", "A=A-1", "D=M", "A=A-1", "D=D+M",
			"M=D", "@SP", "M=M-1", ]

	fwrite(f, list2str(templst) + nl)

func handle_sub(f)
	templst = ["@SP", "A=M", "A=A-1", "D=M", "A=A-1", "D=M-D", 
			"M=D", "@0", "M=M-1", ]

	fwrite(f, list2str(templst) + nl)

func handle_neg(f)
	templst = ["@SP", "A=M", "A=A-1", "M=-M", ]

	fwrite(f, list2str(templst) + nl)

func handle_cmp(f, cmd, counter)
	cond = "D;JEQ"
	if cmd = "gt"
		cond = "D;JGT"
	elseif cmd = "lt"
		cond = "D;JLT"
	ok

	templst = ["@SP", "A=M", "A=A-1", "D=M", "A=A-1", "D=M-D",
			"M=-1", "@IFTRUE" + counter, cond, "@SP", 
			"A=M", "A=A-1","A=A-1", "M=0", 
			"(IFTRUE" +counter + ")", "@SP", "M=M-1", ]

	fwrite(f, list2str(templst) + nl)

func handle_push(f, s, i)
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
		addr = number(i) + 16
		addrstr = "@" + substr(copy(fileName, 1), "vm", i)
	ok

	templst = []
		
	if addr > 0 and addr < 5
		templst = ["@" + i, "D=A", addrstr, "A=D+M", "D=M", "@SP", 
				"A=M", "M=D", "@SP", "M=M+1", ]
	elseif addr = 0
		templst = ["@" + i, "D=A", addrstr, "A=M", "M=D", addrstr, 
				"M=M+1", ]
	else
		templst = [addrstr, "D=M", "@SP", "A=M", "M=D", "@SP",
				"M=M+1", ]
	ok

	fwrite(f, list2str(templst) + nl)

func handle_pop(f, s, i)
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
		addrstr = "@" + substr(copy(fileName, 1), "vm", i)
	ok

	templst = []
	if addr != 0 and addr < 5
		templst = ["@" + i, "D=A", addrstr, "D=D+M", "@R6", "M=D",
				"@SP", "A=M", "A=A-1", "D=M", "@R6", "A=M",
				"M=D", "@SP", "M=M-1", "@R6", "M=0", ]
	else 
		templst = ["@SP", "A=M", "A=A-1", "D=M", addrstr,
				"M=D", "@SP", "M=M-1",  ]
	ok
	

	fwrite(f, list2str(templst) + nl)

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

func handle_notgt(f, counter)
	templst = ["@SP", "A=M", "A=A-1", "D=M", "A=A-1", "D=M-D",
			"M=0", "@IFTRUE" + counter, "D;JGT", "@SP", 
			"A=M", "A=A-1","A=A-1", "M=-1", 
			"(IFTRUE" +counter + ")", "@SP", "M=M-1", ]
	
	fwrite(f, list2str(templst) + nl)


func getToken(line)
	temp = copy(line, 1)
	temp = trim(temp)
	token = []
	cmdPos = substr(temp, " ")
	if cmdPos = 0
		add(token, temp)
	else
		cmd = substr(temp, 1, cmdPos - 1)
		token = [cmd]
		temp = trim(substr(temp, cmdPos+1))
	
		x = 0
		while len(temp) > 0 and x < 3 and temp != " "
			pos = substr(temp, " ")
			tmp = substr(temp, 1, pos)
			if pos = 0
				add(token, temp)
				exit
			ok
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
		
