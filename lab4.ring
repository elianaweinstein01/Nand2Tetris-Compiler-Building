path = "C:\Users\navam\OneDrive\Nava\Machon Tal\Shana Gimmel+\Fundamentals\Lab4\Defense"
createFiles(path)
indentLevel = 0
createGrammarFiles(path)

func createFiles(folder)
	contents = dir(folder)

	for item in contents
		# if item is a folder, go into the folder
		if item[2] = 1
			createFiles(folder + "\" + item[1])
		# if item is a file and ends with .jack
		elseif item[2] = 0 and (right(item[1], 5) = ".jack")
			outputFile = substr(item[1], ".jack", "T.xml")
			tokenize(folder + "\" + item[1], folder + "\" + outputFile)
		ok
	next

func tokenize(jackfile, outputFile)
	# file that we are writing to - open for writing 
	XMLFile = fopen(outputFile, "w")
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
			token = substr(upper(token), 2, len(token)-2)
		ok
		# write the token do the output file
		writeLn = "<" + tokType + "> " + token + " </" + tokType + ">"
		fwrite(XMLFile, writeLn + nl)
		# get the next token
		token = advance(jackFile)
	end
	# once all tokens are extracted, all files end with </tokens>
	fwrite(XMLFile, "</tokens>")
	fclose(XMLFile)

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


func identifier


func intVal


func stringVal

# compiler 

func createGrammarFiles(folder)
	contents = dir(folder)

	for item in contents
		# if item is a folder, go into the folder
		if item[2] = 1
			createGrammarFiles(folder + "\" + item[1])
		# if item is a file and ends with .jack
		elseif item[2] = 0 and (right(item[1], 5) = "T.xml")
			outputFile = substr(item[1], "T.xml", ".xml")
			parse(folder + "\" + item[1], folder + "\" + outputFile)
		ok
	next

func parse(xmlFile, outputFile)
	# file that we are writing to - open for writing 
	parsedFile = fopen(outputFile, "w")
	# open the .jack file for reading
	tokenFile = fopen(xmlFile, "r")
	# skip the first line that says <tokens>
	fgets(tokenFile, 1000)
	# extract a token
	currToken = advanceParser(tokenFile)
	if currToken[2] = "class"
		compileClass(currToken, tokenFile, parsedFile)
	ok

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
	# if see a "terminal" then print the token
	if str = currToken[1]
		printXMLtoken(currToken, outputFile)
	# if we are see an op, unary op or symbol, then print the token
	elseif ((str = "op") or (str = "unaryOp")) and (currToken[1] = "symbol")
		printXMLtoken(currToken, outputFile)
	# if we see the token itself then print the token
	elseif currToken[2] = str
		printXMLtoken(currToken, outputFile)
	# else error
	else
		currToken = ["ERROR", "ERROR"]
		printXMLtoken(currToken, outputFile)
	ok
	# get the next token
	currToken = advanceParser(tokenFile)
	return currToken
# non terminals
func isOp(token)
	ops = ["+", "-", "*", "/", "&amp;", "|", "&lt;", "=", "~", "&gt;", "$"]
	return (token[1] = "symbol") and (find(ops, token[2]) > 0)
func isUnaryOp(token)
	unaryOps = ["~", "-"]
	return (token[1] = "symbol") and (find(unaryOps, token[2]) > 0)
	


func printXMLtoken(currentToken, outputFile)
    writeIndented(outputFile, "<" + currentToken[1] + "> " + currentToken[2] + " </" + currentToken[1] + ">")


# Statements
func compileStatements(currToken, tokenFile, parsedFile)
	# If there are no statements then print empty statement tag
	if currToken[2] = "}"
		writeIndented(parsedFile, "<statements>")
		writeIndented(parsedFile, "</statements>")	
	else
		writeIndented(parsedFile, "<statements>")
    		indentLevel += 1

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

		indentLevel -= 1
    		writeIndented(parsedFile, "</statements>")
	ok
	return currToken


# Let Statement
func compileLet(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<letStatement>")
    	indentLevel += 1

	# let identifier [expr]* = expr ;
	currToken = process("let", tokenFile, parsedFile, currToken)
	currToken = process("identifier", tokenFile, parsedFile, currToken)
	if currToken[2] = "["
		currToken = process("[", tokenFile, parsedFile, currToken)
		currToken = compileExpression(currToken, tokenFile, parsedFile)
		currToken = process("]", tokenFile, parsedFile, currToken)
	ok
	currToken = process("=", tokenFile, parsedFile, currToken)
	currToken = compileExpression(currToken, tokenFile, parsedFile)
	currToken = process(";", tokenFile, parsedFile, currToken)
	
	indentLevel -= 1
    	writeIndented(parsedFile, "</letStatement>")
	return currToken



# If Statement
func compileIf(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<ifStatement>")
    	indentLevel += 1

	# if ( expr ) { statements } 
	currToken = process("if", tokenFile, parsedFile, currToken)
	currToken = process("(", tokenFile, parsedFile, currToken)
	currToken = compileExpression(currToken, tokenFile, parsedFile)
	currToken = process(")", tokenFile, parsedFile, currToken)
	currToken = process("{", tokenFile, parsedFile, currToken)
	currToken = compileStatements(currToken, tokenFile, parsedFile)
	currToken = process("}", tokenFile, parsedFile, currToken)

	# else { statements }
	if currToken[2] = "else"
		currToken = process("keyword", tokenFile, parsedFile, currToken)
		currToken = process("{", tokenFile, parsedFile, currToken)
		currToken = compileStatements(currToken, tokenFile, parsedFile)
		currToken = process("}", tokenFile, parsedFile, currToken)	
	ok
	
	indentLevel -= 1
    	writeIndented(parsedFile, "</ifStatement>")
	return currToken


# While Statement
func compileWhile(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<whileStatement>")
    	indentLevel += 1

	# while ( expr ) { statements }
	currToken = process("while", tokenFile, parsedFile, currToken)
	currToken = process("(", tokenFile, parsedFile, currToken)
	currToken = compileExpression(currToken, tokenFile, parsedFile)
	currToken = process(")", tokenFile, parsedFile, currToken)
	currToken = process("{", tokenFile, parsedFile, currToken)
	currToken = compileStatements(currToken, tokenFile, parsedFile)
	currToken = process("}", tokenFile, parsedFile, currToken)
	
	indentLevel -= 1
    	writeIndented(parsedFile, "</whileStatement>")
	return currToken


# Do Statement
func compileDo(currToken, tokenFile, parsedFile)
	nexttok = peekNextToken(tokenFile)
	if nexttok[2] = "{" 
		return compileDoWhile(currToken, tokenFile, parsedFile)
	else 
		writeIndented(parsedFile, "<doStatement>")
	    	indentLevel += 1
	
	
		# do identifier ( expr , expr* ) ;
		currToken = process("do", tokenFile, parsedFile, currToken)
		currToken = process("identifier", tokenFile, parsedFile, currToken)
		if currToken[2] = "("
			currToken = process("(", tokenFile, parsedFile, currToken)
			currToken = compileExpressionList(currToken, tokenFile, parsedFile)
			currToken = process(")", tokenFile, parsedFile, currToken)
		# do identifier . identifier ( expr , expr* ) ;
		elseif currToken[2] = "."
			currToken = process(".", tokenFile, parsedFile, currToken)
			currToken = process("identifier", tokenFile, parsedFile, currToken)
			currToken = process("(", tokenFile, parsedFile, currToken)
			currToken = compileExpressionList(currToken, tokenFile, parsedFile)
			currToken = process(")", tokenFile, parsedFile, currToken)
		ok
		currToken = process(";", tokenFile, parsedFile, currToken)
		indentLevel -= 1
	    	writeIndented(parsedFile, "</doStatement>")
		return currToken
	ok


#Do While 
func compileDoWhile(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<doWhile>")
	indentLevel += 1

	currToken = process("do", tokenFile, parsedFile, currToken)
	currToken = process("{", tokenFile, parsedFile, currToken)
	
	currToken = compileStatements(currToken, tokenFile, parsedFile)
	currToken = process("}", tokenFile, parsedFile, currToken)
	currToken = process("while", tokenFile, parsedFile, currToken)
	currToken = process("(", tokenFile, parsedFile, currToken)
	currToken = compileExpression(currToken, tokenFile, parsedFile)
	currToken = process(")", tokenFile, parsedFile, currToken)
	currToken = process(";", tokenFile, parsedFile, currToken)

	indentLevel -= 1
	writeIndented(parsedFile, "</doWhile>")

	return currToken


	
# Return Statement
func compileReturn(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<returnStatement>")
    	indentLevel += 1
	
	# return expr* ;
	currToken = process("return", tokenFile, parsedFile, currToken)
	if currToken[2] != ";"
		currToken = compileExpression(currToken, tokenFile, parsedFile)
	ok
	currToken = process(";", tokenFile, parsedFile, currToken)
	indentLevel -= 1
    	writeIndented(parsedFile, "</returnStatement>")
	return currToken



# program structure
func compileClass(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<class>")
    	indentLevel += 1

	# class identifier { static/field* ...
	currToken = process("class", tokenFile, parsedFile, currToken)
	currToken = process("identifier", tokenFile, parsedFile, currToken)
	currToken = process("{", tokenFile, parsedFile, currToken)
	while (currToken[2] = "static") or (currToken[2] = "field")
		currToken = compileClassVarDec(currToken, tokenFile, parsedFile)
	end
	# ... constructor/function* }
	while (currToken[2] = "constructor") or (currToken[2] = "function") or (currToken[2] = "method") or (currToken[2] = "procedure")
		see currToken[2] + nl
		currToken = compileSubroutineDec(currToken, tokenFile, parsedFile)
	end
	currToken = process("}", tokenFile, parsedFile, currToken)
	indentLevel -= 1
    	writeIndented(parsedFile, "</class>")
	return currToken

	
# Class Statics and Fields
func compileClassVarDec(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<classVarDec>")
    	indentLevel += 1
	see "What we get: "
	see currToken + nl
	# static or field
	currToken = process("keyword", tokenFile, parsedFile, currToken)
	see "Process keyword: "
	see currToken + nl
	# int, char, boolean or className
	if currToken[1] = "identifier"
		see "if token is id: "
		see currToken + nl
		currToken = process("identifier", tokenFile, parsedFile, currToken)
	else
		currToken = process("keyword", tokenFile, parsedFile, currToken)
	ok
	currToken = process("identifier", tokenFile, parsedFile, currToken)
	while currToken[2] = ","
		
		currToken = process(",", tokenFile, parsedFile, currToken)
		currToken = process("identifier", tokenFile, parsedFile, currToken)	
	end
	currToken = process(";", tokenFile, parsedFile, currToken)
	indentLevel -= 1
    	writeIndented(parsedFile, "</classVarDec>")
	return currToken


# Class Subroutine Decelerations
func compileSubroutineDec(currToken, tokenFile, parsedFile)
	 writeIndented(parsedFile, "<subroutineDec>")
    	indentLevel += 1
	# constructor, function, procedure, or method
	currToken = process("keyword", tokenFile, parsedFile, currToken)
	# void, int, char, boolean or className
	if currToken[1] = "identifier"
		currToken = process("identifier", tokenFile, parsedFile, currToken)
	else
		currToken = process("keyword", tokenFile, parsedFile, currToken)
	ok
	# subroutine name
	currToken = process("identifier", tokenFile, parsedFile, currToken)
	currToken = process("(", tokenFile, parsedFile, currToken)
	currToken = compileParameterList(currToken, tokenFile, parsedFile)
	currToken = process(")", tokenFile, parsedFile, currToken)
	currToken = compileSubroutineBody(currToken, tokenFile, parsedFile)
	
	indentLevel -= 1
    	writeIndented(parsedFile, "</subroutineDec>")
	return currToken


# Parameter Lists for functions
func compileParameterList(currToken, tokenFile, parsedFile)
	# If no parameters print empty tag
	if currToken[2] = ")"	
		writeIndented(parsedFile, "<parameterList>")
		writeIndented(parsedFile, "</parameterList>")
	else
		writeIndented(parsedFile, "<parameterList>")
    		indentLevel += 1
		# type
		if currToken[1] = "identifier"
			currToken = process("identifier", tokenFile, parsedFile, currToken)
		else
			currToken = process("keyword", tokenFile, parsedFile, currToken)
		ok
		# varName
		currToken = process("identifier", tokenFile, parsedFile, currToken)
		while currToken[2] = ","
			currToken = process(",", tokenFile, parsedFile, currToken)
			# type
			if currToken[1] = "identifier"
				currToken = process("identifier", tokenFile, parsedFile, currToken)
			else
				currToken = process("keyword", tokenFile, parsedFile, currToken)
			ok
			# varName
			currToken = process("identifier", tokenFile, parsedFile, currToken)
		end
		indentLevel -= 1
    		writeIndented(parsedFile, "</parameterList>")
	ok
	return currToken


# Class Subroutines
func compileSubroutineBody(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<subroutineBody>")
    	indentLevel += 1

	# { var* ...
	currToken = process("{", tokenFile, parsedFile, currToken)
	while currToken[2] = "var"
		currToken = compileVarDec(currToken, tokenFile, parsedFile)
	end
	# ... statements* }
	currToken = compileStatements(currToken, tokenFile, parsedFile)
	currToken = process("}", tokenFile, parsedFile, currToken)
	indentLevel -= 1
    	writeIndented(parsedFile, "</subroutineBody>")
	return currToken


# Class Var Declarations 
func compileVarDec(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<varDec>")
    	indentLevel += 1
	currToken = process("keyword", tokenFile, parsedFile, currToken)
	# type
	if currToken[1] = "identifier"
		currToken = process("identifier", tokenFile, parsedFile, currToken)
	else
		currToken = process("keyword", tokenFile, parsedFile, currToken)
	ok
	# varName
	currToken = process("identifier", tokenFile, parsedFile, currToken)
	
	while currToken[2] = ","
		currToken = process(",", tokenFile, parsedFile, currToken)
		# varName
		currToken = process("identifier", tokenFile, parsedFile, currToken)
	end
	currToken = process(";", tokenFile, parsedFile, currToken)
	indentLevel -= 1
    	writeIndented(parsedFile, "</varDec>")
	return currToken


	
# Expressions
func compileExpression(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<expression>")
    	indentLevel += 1
	
	# Deal with the term
	currToken = compileTerm(currToken, tokenFile, parsedFile)
	# Deal with the operation and the next term until there are no more
	#    operations
	while(isOp(currToken))
		currToken = process("op", tokenFile, parsedFile, currToken)
		currToken = compileTerm(currToken, tokenFile, parsedFile)
	end

	indentLevel -= 1
    	writeIndented(parsedFile, "</expression>")
	return currToken

	
# Expression Terms
func compileTerm(currToken, tokenFile, parsedFile)
	writeIndented(parsedFile, "<term>")
    	indentLevel += 1

	if currToken[1] = "identifier"
		currToken = process("identifier", tokenFile, parsedFile, currToken)
		# identifier [ expr ]
		if currToken[2] = "["
			currToken = process("[", tokenFile, parsedFile, currToken)
			currToken = compileExpression(currToken, tokenFile, parsedFile)
			currToken = process("]", tokenFile, parsedFile, currToken)
		# identifier ( expr , expr* ) 
		elseif currToken[2] = "("
			currToken = process("(", tokenFile, parsedFile, currToken)
			currToken = compileExpressionList(currToken, tokenFile, parsedFile)
			currToken = process(")", tokenFile, parsedFile, currToken)
		# identifier . identifier ( expr , expr* )
		elseif currToken[2] = "."
			currToken = process(".", tokenFile, parsedFile, currToken)
			currToken = process("identifier", tokenFile, parsedFile, currToken)
			currToken = process("(", tokenFile, parsedFile, currToken)
			currToken = compileExpressionList(currToken, tokenFile, parsedFile)
			currToken = process(")", tokenFile, parsedFile, currToken)
		ok

	# ints
	elseif currToken[1] = "integerConstant"
		currToken = process("integerConstant", tokenFile, parsedFile, currToken)
	# strings
	elseif currToken[1] = "stringConstant"
		currToken = process("stringConstant", tokenFile, parsedFile, currToken)
	# keywords
	elseif currToken[1] = "keyword"
		currToken = process("keyword", tokenFile, parsedFile, currToken)
	# ( expr , expr* ) 
	elseif currToken[2] = "("
		currToken = process("(", tokenFile, parsedFile, currToken)
		currToken = compileExpression(currToken, tokenFile, parsedFile)
		currToken = process(")", tokenFile, parsedFile, currToken)
	# unary operations + term
	elseif isUnaryOp(currToken)
		currToken = process("unaryOp", tokenFile, parsedFile, currToken)
		currToken = compileTerm(currToken, tokenFile, parsedFile)
	ok
	
	indentLevel -= 1
   	writeIndented(parsedFile, "</term>")
	return currToken

		
# Expression Lists
func compileExpressionList(currToken, tokenFile, parsedFile)
	# If no expressions print empty tag
	if currToken[2] = ")"	
		writeIndented(parsedFile, "<expressionList>")
		writeIndented(parsedFile, "</expressionList>")
	else
		writeIndented(parsedFile, "<expressionList>")
		indentLevel += 1
		# expr , expr* 
		currToken = compileExpression(currToken, tokenFile, parsedFile)
		while currToken[2] = ","
			currToken = process(",", tokenFile, parsedFile, currToken)
			currToken = compileExpression(currToken, tokenFile, parsedFile)
		end
		indentLevel -= 1
		writeIndented(parsedFile, "</expressionList>")
	ok
	return currToken


# Make sure to print with correct indenting
func writeIndented(file, text)
	for i = 1 to indentLevel
        	fwrite(file, "  ")
    	next
    	fwrite(file, text + nl)


func peekNextToken(tokenFile)
    # save current file position
    pos = ftell(tokenFile)

    # read next token as usual
    token = advanceParser(tokenFile)

    # rewind to original position
    fseek(tokenFile, pos, 0)

    return token
