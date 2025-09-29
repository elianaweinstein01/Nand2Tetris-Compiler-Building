path = "C:\Users\navam\OneDrive\Nava\Machon Tal\Shana Gimmel+\Fundamentals\Lab5"
classTable = []      # for static and field
subroutineTable = [] # for arg and var
staticCount = 0
fieldCount = 0
argCount = 0
varCount = 0
ifLabelCounter = 0
whileLoopCounter = 0
className = ""
comment = ""
createTokenFiles(path)


func createTokenFiles(folder)
	contents = dir(folder)

	for item in contents
		# if item is a folder, go into the folder
		if item[2] = 1
			createTokenFiles(folder + "\" + item[1])
		# if item is a file and ends with .jack
		elseif item[2] = 0 and (right(item[1], 5) = ".jack")
			outputFile = substr(item[1], ".jack", "T.xml")
			XMLFile = folder + "\" + outputFile
			outputFile = substr(item[1], ".jack", ".vm")
			vmFile = folder + "\" + outputFile
			tokenize(folder + "\" + item[1], XMLFile)
			
			parse(XMLFile, vmFile)
			
			
		ok
	next

func tokenize(jackfile, xmlFile)
	# file that we are writing to - open for writing 
	XMLFile = fopen(xmlFile, "w")
	# all files start with <tokens>
	fwrite(XMLFile, "<tokens>" + nl)
	# open the .jack file for reading
	jackFile = fopen(jackfile, "r")
	# extract a token
	token = advance(jackFile)
	# while we are not at the end of the jack file:
	while hasMoreTokens(jackFile)
		# identify its type
		tokType = tokenType(token)
		# if its a string, remove the quotes
		if tokType = "stringConstant"
			# strings are CAPITALIZED
			token = substr(token, 2, len(token)-2)
		ok
		# write the token do the output file
		writeLn = "<" + tokType + "> " + token + " </" + tokType + ">"
		fwrite(XMLFile, writeLn + nl)
		# get the next token
		token = advance(jackFile)
	end
	# once all tokens are extracted, all files end with </tokens>
	fwrite(XMLFile, "</tokens>")
	fclose(jackFile)
	fclose(XMlFile)
	

# checks if we've reached the end of the file
func hasMoreTokens(jackFile)
		return feof(jackFile) = 0

# moves the file pointer to find the next token
func advance(jackFile)
	# curr equals the next char in the inout file
	curr = fgetc(jackFile)
	# if we havent reached the end of the file it continues checking
	if hasMoreTokens(jackFile)
		# STRING CONSTANT check
		if curr = '"'
			# while curr is not equal to the end quote
			curr = curr + fgetc(jackFile)
			while right(curr, 1) != '"'
				# get the full string constant
				curr = curr + fgetc(jackFile)
			end
			return curr
		# INTEGER CONSTANT check
		elseif isDigit(curr)
			# get the next char
			nextc = fgetc(jackFile)
			# while the next char is a char
			while isDigit(nextc)
				# append it to the int constant
				curr = curr + nextc
				nextc = fgetc(jackFile)
			end
			# go back one char 
			ungetc(jackFile, nextc)
			return curr
		# identifier / keyword /  check 
		elseif curr = "_" or isalpha(curr)
			nextc = fgetc(jackFile)
			while isalnum(nextc) or nextc = "_"
				curr = curr + nextc
				nextc = fgetc(jackFile)
			end
			ungetc(jackFile, nextc)
			return curr
		# COMMENT check	
		elseif curr = "/"	
			# if next char = /, its a comment //
			nextc = fgetc(jackFile)
			if nextc = "/"
				# while we havent reached the end of a line
				while iscntrl(nextc) = 0
					# we ignore the next chars
					nextc = fgetc( jackFile)
				end
				return advance(jackFile)
			# checks for the second type of comment
			elseif nextc = "*"
				temp = nextc
				while right(temp, 2) != "*/"
					temp = temp + fgetc( jackFile)
				end
				return advance(jackFile) 	
			else
				return curr
			ok
		elseif curr = "<"
			return "&lt;"
		elseif curr = ">"
			return "&gt;"
		elseif curr = "&"
			return "&amp;"
		elseif symbol(curr) 
			return curr
		else
			return advance(jackFile)
		ok
			
	else
		return null
	ok

# identifies the type of the token that is inputted
func tokenType(token)

	keywords = ["class", "constructor", "function", "method", "field", 
			"static", "var", "int", "char", "boolean", "void", 
			"true", "false", "null", "this", "let", "do", 
			"if", "else", "while","return", "procedure" ]

	symbols = ['{',  '}', '(',  ')',  '[', ']',  '.',  ',', ';', '+', 
			'-', '*', '/',  '&', '|',  '<', '>', '=', '~', "$" ]
	# if it starts with a digit its an integerConstant
	if isDigit(token)
		return "integerConstant"
	# if its in the keyword array, its a keyword
	elseif find(keywords, token) > 0
		return "keyword"
	# if it starts with a quote, its a stringConstant
	elseif token[1] = '"'
		return "stringConstant"
	# if it starts with a char or _ its an identifier
	elseif isalpha(token[1]) or token[1] = "_"
		return "identifier"
	# otherwise its a symbol
	else
		return "symbol"
	ok

# these arent used as of now
func keyWord(x)
	keywords = ["class", "constructor", "function", "method", "field", 
			"static", "var", "int", "char", "boolean", "void", 
			"true", "false", "null", "this", "let", "do", "if", 
			"else", "while", "return", "procedure"]
	return find(keywords, x) > 0


func symbol(x)	
	symbols = ['{',  '}', '(',  ')',  '[', ']',  '.',  
				',', ';', '+', '-', '*', '/',  '&', 
				'|',  '<', '>', '=', '~', "$", ]

	return find(symbols, x) > 0


# compiler 

	

func parse(tokenfile, outputFile)
	# file that we are writing to - open for writing 
	tokenFile = fopen(tokenfile, "r")
	vmFile = fopen(outputFile, "w")
	# skip the first line that says <tokens>
	fgets(tokenFile, 1000)
	# extract a token
	currToken = advanceParser(tokenFile)
	if currToken[2] = "class"
		compileClass(currToken, tokenFile, vmFile)
	ok
	fclose(vmFile)
	fclose(tokenFile)

# moves the file pointer to find the next token
func advanceParser(tokenFile)
	if hasMoreTokens(tokenFile)
	# curr equals the current line of the token file
		curr = fgetc(tokenFile)
		curr = fgetc(tokenFile)
		tokenType = ""
		# get the token type from the tag in the TXML file
		while curr != ">"
			tokenType = tokenType + curr
			curr = fgetc(tokenFile)
		end
		# end of the file
		if tokenType = "/tokens"
			return null
		ok
		# get the token 
		curr = fgetc(tokenFile)
		token = ""
		while curr != "<"
			token = token + curr
			curr = fgetc(tokenFile)
		end
		token = right(token, len(token) - 1)
		token = left(token, len(token) - 1)

		# move the stream to the next token
		fgets(tokenFile, 1000)
		return [tokenType,token]
	ok
	return ["EOF", "EOF"]

# Process the tokens
func process(str, tokenFile, outputFile, currToken)
	
	currToken = advanceParser(tokenFile)
	return currToken

# non terminals
func isOp(token)
	ops = ["+", "-", "*", "/", "&amp;", "|", "&lt;", "=", "~", "&gt;", "$"]
	return (token[1] = "symbol") and (find(ops, token[2]) > 0)
func isUnaryOp(token)
	unaryOps = ["~", "-"]
	return (token[1] = "symbol") and (find(unaryOps, token[2]) > 0)
	

func compileClass(currToken, tokenFile, vmFile)
	
	# class identifier { static/field* ...
	currToken = process("class", tokenFile, vmFile, currToken)
	className = currToken[2]
	comment = "class " + className + " {"
	writeComment(vmFile)

	currToken = process("identifier", tokenFile, vmFile, currToken)
	currToken = process("{", tokenFile, vmFile, currToken)
	while (currToken[2] = "static") or (currToken[2] = "field")
		currToken = compileClassVarDec(currToken, tokenFile, vmFile)
	end
	# ... constructor/function* }
	while (currToken[2] = "constructor") or (currToken[2] = "function") or (currToken[2] = "method") or (currToken[2] = "procedure")
		
		currToken = compileSubroutineDec(currToken, tokenFile, vmFile)
	end
	currToken = process("}", tokenFile, vmFile, currToken)
	
	classTable = []
	staticCount = 0
	fieldCount = 0
	ifLabelCounter = 0
	whileLoopCounter = 0
	return currToken



func compileClassVarDec(currToken, tokenFile, vmFile)
	kind = currToken[2]
	
	currToken = process("keyword", tokenFile, vmFile, currToken)
	type = currToken[2]
	
	# int, char, boolean or className
	if currToken[1] = "identifier"
		currToken = process("identifier", tokenFile, vmFile, currToken)
	else
		currToken = process("keyword", tokenFile, vmFile, currToken)
	ok
	name = currToken[2]
	addToTable(kind, type, name)
	comment = kind + " " + type + " " + name + ";"
	writeComment(vmFile)
	currToken = process("identifier", tokenFile, vmFile, currToken)
	while currToken[2] = ","
		currToken = process(",", tokenFile, vmFile, currToken)
		addToTable(kind, type, currToken[2])
		comment = kind + " " + type + " " + currToken[2] + ";"
		writeComment(vmFile)
		currToken = process("identifier", tokenFile, vmFile, currToken)
			
	end
	currToken = process(";", tokenFile, vmFile, currToken)
	return currToken


func compileSubroutineDec(currToken, tokenFile, vmFile)
	
	subroutineTable = []
	argCount = 0
	varCount = 0
	type = currToken[2]
	comment = type + " "
	if type = "method"
		argCount = 1
	ok
	name = className + "."
	
	currToken = process("keyword", tokenFile, vmFile, currToken)
	# void, int, char, boolean or className
	if currToken[1] = "identifier"
		currToken = process("identifier", tokenFile, vmFile, currToken)
	else
		currToken = process("keyword", tokenFile, vmFile, currToken)
	ok
	# subroutine name
	name = name + currToken[2]
	comment = comment + currToken[2] + "("
	currToken = process("identifier", tokenFile, vmFile, currToken)
	currToken = process("(", tokenFile, vmFile, currToken)
	currToken = compileParameterList(currToken, tokenFile, vmFile)
	currToken = process(")", tokenFile, vmFile, currToken)
	comment += ") {"
	writeComment(vmFile)
	currToken = compileSubroutineBody(currToken, tokenFile, vmFile, name, type)

	return currToken


func compileParameterList(currToken, tokenFile, vmFile)

	# If no parameters print empty tag
	if currToken[2] = ")"	
		return currToken
	else
		# type
		type = currToken[2]
		if currToken[1] = "identifier"
			currToken = process("identifier", tokenFile, vmFile, currToken)
		else
			currToken = process("keyword", tokenFile, vmFile, currToken)
		ok
		name = currToken[2]
		addToTable("argument", type, name)
		# varName
		comment += name
		currToken = process("identifier", tokenFile, vmFile, currToken)
		while currToken[2] = ","
			currToken = process(",", tokenFile, vmFile, currToken)
			# type
			type = currToken[2]
			if currToken[1] = "identifier"
				currToken = process("identifier", tokenFile, vmFile, currToken)
			else
				currToken = process("keyword", tokenFile, vmFile, currToken)
			ok
			name = currToken[2]
			addToTable("argument", type, name)
			# varName
			comment = comment + ", " + name
			currToken = process("identifier", tokenFile, vmFile, currToken)
		end
	ok
	return currToken


func compileSubroutineBody(currToken, tokenFile, vmFile, name, type)
	currToken = process("{", tokenFile, vmFile, currToken)
	numVars = 0
	while currToken[2] = "var"
		result = compileVarDec(currToken, tokenFile, vmFile)
		currToken = result[1]
		numVars += result[2]
	end
	
	
	writeFuncDec(vmFile, name, numVars)
	if type = "constructor"
		writePush(vmFile, "constant", fieldCount)
		writeFuncCall(vmFile, "Memory.alloc", 1)
		writePop(vmFile, "pointer", 0)
		
	elseif type = "method"
		writePush(vmFile, "argument", 0)
		writePop(vmFile, "pointer", 0)
	ok

	# ... statements* }
	currToken = compileStatements(currToken, tokenFile, vmFile)
	currToken = process("}", tokenFile, vmFile, currToken)
	return currToken


func compileVarDec(currToken, tokenFile, vmFile)
	numVars = 0

	currToken = process("keyword", tokenFile, vmFile, currToken)
	# type
	type = currToken[2]
	if currToken[1] = "identifier"
		currToken = process("identifier", tokenFile, vmFile, currToken)
	else
		currToken = process("keyword", tokenFile, vmFile, currToken)
	ok
	# varName
	name = currToken[2]
	numVars += 1
	addToTable("local", type, name)
	comment = type + " " + name 
	currToken = process("identifier", tokenFile, vmFile, currToken)
	
	while currToken[2] = ","
		currToken = process(",", tokenFile, vmFile, currToken)
		# varName
		name = currToken[2]
		comment = comment + ", " + name
		numVars += 1
		addToTable("local", type, name)

		currToken = process("identifier", tokenFile, vmFile, currToken)
	end
	comment += ";"
	writeComment(vmFile)
	currToken = process(";", tokenFile, vmFile, currToken)
	return [currToken, numVars]
	


func addToTable(kind, type, name)
	if kind = "static"
		entry = [name, type, kind, staticCount]
		add(classTable, entry)
		staticCount += 1
	elseif kind = "field"
		entry = [name, type, "this", fieldCount]
		add(classTable, entry)
		fieldCount += 1
	elseif kind = "argument"
		entry = [name, type, kind, argCount]
		add(subroutineTable, entry)
		argCount += 1
	elseif kind = "local"
		entry = [name, type, kind, varCount]
		add(subroutineTable, entry)
		varCount += 1
	ok



# Statements
func compileStatements(currToken, tokenFile, parsedFile)
	# If there are no statements then print empty statement tag
	if currToken[2] = "}"
		return currToken	
	else

		# deal with the types of statements
		while (currToken[2] = "let") 
			or (currToken[2] = "if") 
			or (currToken[2] = "while") 
			or (currToken[2] = "do") 
			or (currToken[2] = "return")

			if currToken[2] = "let"
				currToken = compileLet(currToken, tokenFile, parsedFile)
			elseif currToken[2] = "if"
				currToken = compileIf(currToken, tokenFile, parsedFile)
			elseif currToken[2] = "while"
				currToken = compileWhile(currToken, tokenFile, parsedFile)
				elseif currToken[2] = "do"
				currToken = compileDo(currToken, tokenFile, parsedFile)
			elseif currToken[2] = "return"
				currToken = compileReturn(currToken, tokenFile, parsedFile)
			ok
		end


	ok
	return currToken



# Let Statement
func compileLet(currToken, tokenFile, vmFile)

	# let identifier [expr]* = expr ;
	currToken = process("let", tokenFile, vmFile, currToken)
	name = currToken[2]
	comment = "let " + name 
	writeComment(vmFile)
	kind = kindOf(name)
	type = typeOf(name)
	index = indexOf(name)
	
	currToken = process("identifier", tokenFile, vmFile, currToken)
	if currToken[2] = "["
    		currToken = process("[", tokenFile, vmFile, currToken)

	    	currToken = compileExpression(currToken, tokenFile, vmFile)
		writePush(vmFile, kind, index)
	    	writeop(vmFile, "+")

	    	currToken = process("]", tokenFile, vmFile, currToken)
	
	    	currToken = process("=", tokenFile, vmFile, currToken)
	    	currToken = compileExpression(currToken, tokenFile, vmFile)
		currToken = process(";", tokenFile, vmFile, currToken)

	    	# Save value to temp before setting THAT
		writePop(vmFile, "temp", 0)
		writePop(vmFile, "pointer", 1)
		writePush(vmFile, "temp", 0)
		writePop(vmFile, "that", 0)

	else
	    	currToken = process("=", tokenFile, vmFile, currToken)
	    	currToken = compileExpression(currToken, tokenFile, vmFile)
		currToken = process(";", tokenFile, vmFile, currToken)
	    	if kind != "none" and index >= 0
		    writePop(vmFile, kind, index)
		ok
	ok
	


	return currToken



# If Statement
func compileIf(currToken, tokenFile, vmFile)

	# Label counters
	trueLabel = "IF_TRUE" + string(ifLabelCounter)
	falseLabel = "IF_FALSE" + string(ifLabelCounter)
	endLabel = "IF_END" + string(ifLabelCounter)
	ifLabelCounter += 1

	# if ( expression ) { statements }
	currToken = process("if", tokenFile, vmFile, currToken)
	comment = "if"
	writeComment(vmFile)
	currToken = process("(", tokenFile, vmFile, currToken)
	currToken = compileExpression(currToken, tokenFile, vmFile)
	writeIfgoto(vmFile, trueLabel)         # if condition true -> jump to trueLabel
	writeGoto(vmFile, falseLabel)          # otherwise jump to falseLabel
	currToken = process(")", tokenFile, vmFile, currToken)

	writeLabel(vmFile, trueLabel)          # <IF_TRUE>
	currToken = process("{", tokenFile, vmFile, currToken)
	currToken = compileStatements(currToken, tokenFile, vmFile)
	currToken = process("}", tokenFile, vmFile, currToken)

	# else { statements }
	if currToken[2] = "else"
		comment = "else"
		writeComment(vmFile)
		writeGoto(vmFile, endLabel)        # skip else clause after true branch
		writeLabel(vmFile, falseLabel)     # <IF_FALSE>
		currToken = process("keyword", tokenFile, vmFile, currToken)
		currToken = process("{", tokenFile, vmFile, currToken)
		currToken = compileStatements(currToken, tokenFile, vmFile)
		currToken = process("}", tokenFile, vmFile, currToken)
		writeLabel(vmFile, endLabel)       # <IF_END>
	else
		writeLabel(vmFile, falseLabel)     # <IF_FALSE> (no else clause)
	ok

	return currToken



# While Statement
func compileWhile(currToken, tokenFile, vmFile)

	startLabel = "LOOP_START" + string(whileLoopCounter)
	whileLoopCounter += 1
	endLabel = "LOOP_END"  + string(whileLoopCounter)
	whileLoopCounter += 1

	writeLabel(vmFile, startLabel)

	# while ( expr ) { statements }
	comment = "while"
	writeComment(vmFile)
	currToken = process("while", tokenFile, vmFile, currToken)
	currToken = process("(", tokenFile, vmFile, currToken)
	currToken = compileExpression(currToken, tokenFile, vmFile)

	writeop(vmFile, "~")
	writeIfgoto(vmFile, endLabel)

	currToken = process(")", tokenFile, vmFile, currToken)
	currToken = process("{", tokenFile, vmFile, currToken)

	currToken = compileStatements(currToken, tokenFile, vmFile)
	writeGoto(vmFile, startLabel)

	currToken = process("}", tokenFile, vmFile, currToken)

	fwrite(vmFile, nl)
	writeLabel(vmFile, endLabel)
	
	return currToken


# Do Statement
func compileDo(currToken, tokenFile, vmFile)
    	currToken = process("do", tokenFile, vmFile, currToken)
    	name = currToken[2]  # could be class or var name
    	currToken = process("identifier", tokenFile, vmFile, currToken)
	comment = "do " 
    	if currToken[2] = "."  # method call on an object or static function
        	currToken = process(".", tokenFile, vmFile, currToken)
        	methodName = currToken[2]
        	currToken = process("identifier", tokenFile, vmFile, currToken)
		fullName = ""
        	# Check if name is a variable (i.e., method call)
        	if kindOf(name) != "none"
            		type = typeOf(name)
            		kind = kindOf(name)
            		index = indexOf(name)
            		writePush(vmFile, kind, index)
            		fullName = type + "." + methodName
            		methodCall = true
       		else	
            		# static call like Math.multiply
            		fullName = name + "." + methodName
            		methodCall = false
        	ok
		comment += fullName
		writeComment(vmFile)
        	currToken = process("(", tokenFile, vmFile, currToken)
        	result = compileExpressionList(currToken, tokenFile, vmFile)
		currToken = result[1]
		numArgs = result[2]
        	if methodCall
            		numArgs += 1  # include `this`
        	ok
        	currToken = process(")", tokenFile, vmFile, currToken)
        	writeFuncCall(vmFile, fullName, numArgs)
    	else
        	# this is a call like do run(); assume method in same class
        	writePush(vmFile, "pointer", 0)  # push this
        	fullName = className + "." + name
        	currToken = process("(", tokenFile, vmFile, currToken)
        	result = compileExpressionList(currToken, tokenFile, vmFile)
		currToken = result[1]
		numArgs = result[2]
        	writeFuncCall(vmFile, fullName, numArgs + 1)
        	currToken = process(")", tokenFile, vmFile, currToken)
    	ok

    	writePop(vmFile, "temp", 0)  # discard return value
	fwrite(vmFile, nl)
    	currToken = process(";", tokenFile, vmFile, currToken)
    	return currToken





	
# Return Statement
func compileReturn(currToken, tokenFile, vmFile)
	
	# return expr* ;
	currToken = process("return", tokenFile, vmFile, currToken)
	
	if currToken[2] != ";"
		if currToken[2] = "this"
			currToken = process("keyword", tokenFile, vmFile, currToken)
			writePush(vmFile, "pointer", 0)
		else
			currToken = compileExpression(currToken, tokenFile, vmFile)
		ok
	else 
		writePush(vmFile, "constant", 0)
	ok
	currToken = process(";", tokenFile, vmFile, currToken)
	fwrite(vmFile, "return" + nl + nl)

	return currToken



# Expressions
func compileExpression(currToken, tokenFile, vmFile)
	
	# Deal with the term
	currToken = compileTerm(currToken, tokenFile, vmFile)
	# Deal with the operation and the next term until there are no more
	#    operations
	while (isOp(currToken))
		op = currToken[2]
		currToken = process("op", tokenFile, vmFile, currToken)
		currToken = compileTerm(currToken, tokenFile, vmFile)
		writeop(vmFile, op)
	end

	return currToken


# Expression Terms
func compileTerm(currToken, tokenFile, vmFile)

	if currToken[1] = "identifier"

		nextToken = peekNextToken(tokenFile)
    		if nextToken[2] = "(" or nextToken[2] = "."
        		result = compileSubroutineCall(currToken, tokenFile, vmFile)
        		currToken = result[1]
		else
			name = currToken[2]
			kind = kindOf(name)
			type = typeOf(name)
			index = indexOf(name)
			funcName = name
			currToken = process("identifier", tokenFile, vmFile, currToken)
			if kind != "none" and index >= 0 and currToken[2] != "["
				writePush(vmFile, kind, index)
			ok
		ok


		# identifier [ expr ]
		if currToken[2] = "["
    			currToken = process("[", tokenFile, vmFile, currToken)
			# if kind != "none" and index >= 0
		        	# writePush(vmFile, kind, index)
		    	# ok
    			currToken = compileExpression(currToken, tokenFile, vmFile)  # push index
    			writePush(vmFile, kind, index)                             # push base
    			writeop(vmFile, "+") 
			currToken = process("]", tokenFile, vmFile, currToken)                                        # addr = base + index
    			writePop(vmFile, "pointer", 1)                               # that = addr
    			writePush(vmFile, "that", 0)                                 # push value at arr[i]

		# identifier ( expr , expr* ) 
		elseif currToken[2] = "("
			currToken = process("(", tokenFile, vmFile, currToken)
			result = compileExpressionList(currToken, tokenFile, vmFile)
			currToken = result[1]
			numArgs = result[2]
			writeFuncCall(vmFile, className + "." + funcName, numArgs)
			currToken = process(")", tokenFile, vmFile, currToken)
		# identifier . identifier ( expr , expr* )
		elseif currToken[2] = "."
			currToken = process(".", tokenFile, vmFile, currToken)
			numArgs = 0
			if kind != "none" and index >= 0
				funcName = type + "." + currToken[2]
				writePush(vmFile, "local", 0)
				numArgs = 1
			else 
				funcName = funcName + "." + currToken[2]
			ok
			
			currToken = process("identifier", tokenFile, vmFile, currToken)
			currToken = process("(", tokenFile, vmFile, currToken)
			result = compileExpressionList(currToken, tokenFile, vmFile)
			currToken = result[1]
			numArgs = numArgs + result[2]
			writeFuncCall(vmFile, funcName, numArgs)
			currToken = process(")", tokenFile, vmFile, currToken)
		ok

	# ints
	elseif currToken[1] = "integerConstant"
		writePush(vmFile, "constant", currToken[2])
		currToken = process("integerConstant", tokenFile, vmFile, currToken)
	# strings
	elseif currToken[1] = "stringConstant"
		writeString(vmFile, currToken[2])
		currToken = process("stringConstant", tokenFile, vmFile, currToken)
	# keywords
	elseif currToken[1] = "keyword"
		if currToken[2] = "true"
			writePush(vmFile, "constant", 0)
			writeop(vmFile, "~")
		elseif currToken[2] = "false" or currToken[2] = "null"
			writePush(vmFile, "constant", 0)
		elseif currToken[2] = "this"
			writePush(vmFile, "pointer", 0)
		ok

		currToken = process("keyword", tokenFile, vmFile, currToken)
	# ( expr , expr* ) 
	elseif currToken[2] = "("
		currToken = process("(", tokenFile, vmFile, currToken)
		currToken = compileExpression(currToken, tokenFile, vmFile)
		currToken = process(")", tokenFile, vmFile, currToken)
	# unary operations + term
	elseif isUnaryOp(currToken)
		op = currToken[2]
		if currToken[2] = "-"
			op = "neg"
		ok

		currToken = process("unaryOp", tokenFile, vmFile, currToken)
		currToken = compileTerm(currToken, tokenFile, vmFile)
		writeop(vmFile, op)
	ok

	return currToken

		
# Expression Lists
func compileExpressionList(currToken, tokenFile, vmFile)
	numArgs = 0
	# If no expressions print empty tag
	if currToken[2] != ")"		
		# expr , expr* 
		currToken = compileExpression(currToken, tokenFile, vmFile)
		numArgs += 1
		while currToken[2] = ","
			currToken = process(",", tokenFile, vmFile, currToken)
			currToken = compileExpression(currToken, tokenFile, vmFile)
			numArgs += 1
		end
	
	ok
	return [currToken, numArgs]


func compileSubroutineCall(currToken, tokenFile, vmFile)

    # First token is the name of the function/class/variable
   	name = currToken[2]
    	currToken = process("identifier", tokenFile, vmFile, currToken)

    	methodCall = false
    	numArgs = 0

    	if currToken[2] = "."
    	    	currToken = process(".", tokenFile, vmFile, currToken)
        	subroutineName = currToken[2]
        	currToken = process("identifier", tokenFile, vmFile, currToken)
	

        	# Check if 'name' is a variable (i.e., method call)
        	if kindOf(name) != "none"
            		type = typeOf(name)         # get the class type of the object
            		kind = kindOf(name)
            		index = indexOf(name)
            		writePush(vmFile, kind, index)  # push the object as 'this'
            		fullName = type + "." + subroutineName
            		methodCall = true
        	else
            		# Static/class function
            		fullName = name + "." + subroutineName
		ok

    	elseif currToken[2] = "("
        	# It’s a call like: subroutineName(exprList), implicit this
        	fullName = className + "." + name
        	writePush(vmFile, "pointer", 0)  # push 'this'
        	methodCall = true
	ok

    	# Now handle expression list
    	currToken = process("(", tokenFile, vmFile, currToken)
    	result = compileExpressionList(currToken, tokenFile, vmFile)
    	currToken = result[1]
    	numArgs = result[2]
    	currToken = process(")", tokenFile, vmFile, currToken)

    	if methodCall
        	numArgs += 1  # account for pushed 'this'
	ok

    	writeFuncCall(vmFile, fullName, numArgs)

    	return [currToken, numArgs]



func writePush(vmFile, segment, index)
	
	if segment = "constant" and number(index) < 0
		writePush(vmFile, "constant", 0)
		writeop(vmFile, "~")
	else
		fwrite(vmFile, "push " + segment + " " + string(index) + nl)
	ok


func writePop(vmFile, segment, index)
	output = "pop " + segment + " " + string(index)
	fwrite(vmFile, output + nl)


func writeString(vmFile, str_)
	str = str_
	writePush(vmFile, "constant", len(str))
	fwrite(vmFile, "call String.new 1" + nl)

	for i in str 
		writePush(vmFile, "constant", ascii(i))
		fwrite(vmFile, "call String.appendChar 2" + nl)
	next
	// fwrite(vmFile, "call Output.printString 1" + nl)
	// fwrite(vmFile, "pop temp 0" + nl)

	


func writeop(vmFile, op)
	op_ = ""
	if op = "+"
		op_ = "add"
	elseif op = "-"
		op_ = "sub"
	elseif op = "*"
		op_ = "call Math.multiply 2"
	elseif op = "/"
		op_ = "call Math.divide 2"
	elseif op = "="
		op_ = "eq"
	elseif op = "&gt;"
		op_ = "gt"
	elseif op = "&lt;"
		op_ = "lt"
	elseif op = "&amp;"
		op_ = "and"
	elseif op = "|"
		op_ = "or"
	elseif op = "~"
		op_ = "not"
	else
		op_ = op
	ok

	fwrite(vmFile, op_ + nl)


func writeIfgoto(vmFile, label)
	fwrite(vmFile, "if-goto " + label + nl)


func WriteGoto(vmFile, label)
	fwrite(vmFile, "goto " + label + nl)


func writeLabel(vmFile, label)
	fwrite(vmFile, "label " +label + nl)


func writeFuncCall(vmFile, funcName, numArgs)
	fwrite(vmFile, "call " + funcName + " " + string(numArgs) + nl)


func writeFuncDec(vmFile, funcName, numArgs)
	fwrite(vmFile, "function " + funcName + " " + string(numArgs) + nl)

func writeComment(vmFile)
	fwrite(vmFile, "//" + comment + nl)


func kindOf(name)
	for entry in subroutineTable
		if entry[1] = name
			return entry[3]
		ok
	next
	for entry in classTable
		if entry[1] = name
			return entry[3]
		ok
	next
	return "none"


func typeOf(name)
	for entry in subroutineTable
		if entry[1] = name
			return entry[2]
		ok
	next
	for entry in classTable
		if entry[1] = name
			return entry[2]
		ok
	next
	return "none"


func indexOf(name)
	for entry in subroutineTable
		if entry[1] = name
			return entry[4]
		ok
	next
	for entry in classTable
		if entry[1] = name
			return entry[4]
		ok
	next
	return -1


func peekNextToken(tokenFile)
    # save current file position
    pos = ftell(tokenFile)

    # read next token as usual
    token = advanceParser(tokenFile)

    # rewind to original position
    fseek(tokenFile, pos, 0)

    return token




