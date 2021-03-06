; Author: Brian Gong
; Section: 1002
; Date Last Modified: WRITE DATE HERE
; Program Description: Use conditional loops and jumps in x86

section .data ; **********************************************************************************
	; System service call values
	programEnd equ 60
	finish equ 0


	; double word arrays

	; int income[] = "..."
	income dd 2623050, 2001216, 2234775, 917928, 1651860, 2785944, 2867940, 1426334, 3445403, 321312
			dd 2227471, 4550044, 5693760, 4315778, 1129436, 2914947, 2922605, 4048278, 2577665, 1189755
			dd 1149910, 4771482, 2938604, 5418294, 4168236, 3323200, 1147806, 3888342, 1166384, 2259264
			dd 2931360, 3199300, 1972840, 3827702, 6241932, 1965182, 3715480, 584675, 2703380, 1227150
			dd 883803, 2879740, 4942170, 5211360, 2864330, 980640, 2175500, 937584, 4923562, 5716340
			dd 1771740, 1096532, 5166720, 5664483, 2949450, 6088170, 2474469, 2992975, 3363267, 5709758
			dd 3488940, 4967768, 1966440, 3789874, 2897174, 4566132, 1296412, 3729418, 4131382, 335676
			dd 2343118, 4012624, 1813645, 3712176, 3150976, 3286752, 367524, 2332174, 1256904, 1149408
			dd 4685213, 2279030, 2442830, 337700, 5050752, 4338564, 4893858, 3499272, 2723440, 4208708
			dd 1831123, 2782410, 1701088, 2794230, 1996412, 2349500, 3069142, 3572285, 4626192, 2032506

	; int expenses[] = "..."
	expenses dd 1322279, 503753, 563344, 1176344, 971840, 778305, 1400947, 986725, 605207, 1361759
				dd 829895, 746045, 1357201, 1292539, 1145571, 1195105, 1221781, 1324924, 1211537, 676675
				dd 834180, 764255, 598365, 1429762, 807940, 914853, 853706, 1013334, 803670, 794454
				dd 886489, 1349721, 777289, 694460, 1248321, 1370640, 1211898, 810188, 817132, 756192
				dd 1046625, 890519, 1459755, 1410694, 651661, 1351063, 663862, 1107541, 1244732, 929763
				dd 1172956, 1042143, 1043792, 979506, 1262030, 570394, 610862, 579591, 1101513, 1322892
				dd 516834, 928870, 1372861, 1384850, 1347583, 1383582, 761759, 547566, 1490124, 951916
				dd 1496162, 554149, 1335786, 1386474, 1446764, 910098, 1247993, 1413991, 1248019, 774009
				dd 1110959, 909827, 803093, 745410, 1058486, 998513, 791917, 1041561, 923280, 815781
				dd 547680, 1045567, 803765, 1180309, 637734, 751832, 752571, 918934, 1275003, 865797

	; int customers[] = "..."
	customers dd 4350, 4467, 5385, 6039, 5130, 3864, 6780, 3227, 6253, 6694
				dd 3901, 5206, 6590, 6113, 5852, 5141, 5285, 5538, 4205, 6295
				dd 3898, 5898, 4786, 5451, 4262, 6200, 6138, 4947, 4336, 5043
				dd 5910, 5350, 5332, 4997, 6267, 7069, 6406, 3341, 4582, 4545
				dd 5853, 5255, 5553, 6204, 5810, 4540, 4351, 4596, 5249, 5833
				dd 6562, 4588, 6210, 5919, 5618, 6270, 5391, 6301, 5451, 6247
				dd 5460, 5164, 4682, 5557, 5593, 5508, 6058, 4367, 5953, 5086
				dd 3743, 6514, 5615, 5288, 3296, 4891, 4428, 4721, 4968, 7368
				dd 4937, 6110, 4085, 3070, 5637, 5927, 5331, 4716, 4720, 5341
				dd 4781, 4890, 4012, 3930, 5338, 4625, 4049, 6065, 6218, 5943


	; variables
	listSizes equ 100 

	incomeTotal dd 0
	expensesTotal dd 0
	customerTotal dd 0

	min dd 0
	max dd 0




section .bss ; ***********************************************************************************
; Uninitialized Data
	grossProfitsPerCustomer resd listSizes
	totalGrossProfit resd 1
	averageGrossProfit resd 1
	highestCostPerCustomer resd 1
	lowestIncomePerCustomer resd 1
	profitableStoreCount resd 1


section .text ; **********************************************************************************
global _start
_start:

	; loop to add up income

	mov rcx, listSizes ; total size of array
	mov rbx, 0 ; loop counter value
	incomeSumLoop: ; (for int i = listSizes; i > 0; i++)
		; totalIncome (ax) = income[i] + income[i+1]
		add eax, dword[income + rbx * 4]
		inc rbx
		dec rcx ; listSizes--
		cmp rcx, 0 
	jne incomeSumLoop ; conditional jump to stay in loop
	mov dword[incomeTotal], eax ; put total value into variable
	
	mov eax, 0 ; reset the eax register



	; loop to add up expenses 

	mov rcx, listSizes 
	mov rbx, 0 
	expensesSumLoop: 
		; totalExpenses (ax) = expenses[i] + expenses[i+1]
		add eax, dword[expenses + rbx * 4] 
		inc rbx
		dec rcx 
		cmp rcx, 0
	jne expensesSumLoop 
	mov dword[expensesTotal], eax
	
	mov eax, 0



	; loop to add up customers
	mov rcx, listSizes 
	mov rbx, 0 
	customerSumLoop: 
		; totalCustomers = customers[i] + customers[i+1]
		add eax, dword[customers + rbx * 4]
		inc rbx
		dec rcx 
		cmp rcx, 0 
	jne customerSumLoop 
	mov dword[customerTotal], eax

	mov eax, 0


	; totalGrossProfit = sum (income) - sum(expenses)
	mov rcx, listSizes
	mov rbx, 0 ; loop counter value
	mov r9d, 0 ; sum value
	calculateGrossProfitSumLoop:
		add r9d, dword[incomes + rbx * 4]
		sub r9d, dword[expenses + rbx * 4]
		
		inc rbx
	loop calculateGrossProfitSumLoop

	mov dword[totalGrossProfit], r9d


	; average gross profit = totalGrossProfit / 100
	mov eax, r9d ; use r9d register
	cdq ; doubleword to quadword extension
	mov ecx, listSizes
	idiv ecx
	mov dword[averageGrossProfit], eax


	; highestCostPerCustomer = maximum(expenses[i]/customer[i])
	mov rcx, STORE_COUNT-1
	mov rbx, 1
	mov eax, dword[expenses]
	cdq
	mov r8d, dword[customers]
	idiv r8d
	mov r8d, eax ; highest cost per customer
	findHighestCostLoop:
		mov eax, dword[expenses + rbx * 4]
		cdq
		mov r9d, dword[customers + rbx * 4]
		idiv r9d
		
		cmp eax, r8d
		jle nextHighest
			mov r8d, eax
		nextHighest:
		
		inc rbx
	loop findHighestCostLoop

	mov dword[highestCostPerCustomer], r8d


	; lowestIncomePerCustomer = minimum(incomes[i]/customer[i])
	mov rcx, STORE_COUNT-1
	mov rbx, 1
	mov eax, dword[incomes]
	cdq
	mov r8d, dword[customers]
	idiv r8d
	mov r8d, eax ; lowest income per customer
	findLowestIncomeLoop:
		mov eax, dword[incomes + rbx * 4]
		cdq
		mov r9d, dword[customers + rbx * 4]
		idiv r9d
		
		cmp eax, r8d
		jge nextLowest
			mov r8d, eax
		nextLowest:
		
		inc rbx
	loop findLowestIncomeLoop

	mov dword[lowestIncomePerCustomer], r8d


	; profitableCount = count(incomes[i] – expenses[i] > 0)
	mov rcx, listSize
	mov rbx, 0 
	mov eax, 0 ; loop counter value
	countProfitableLoop:
		mov r8d, dword[incomes + rbx * 4]
	
		cmp r8d, dword[expenses + rbx * 4]
		jle skipCount ; less than or equal to
			inc eax
		skipCount:
	
		inc rbx
	loop countProfitableLoop

	mov dword[profitableStoreCount], eax


	; grossProfitPerCustomer[i] = (incomes[i]-expenses[i])/customers[i]
	mov rcx, listSize
	mov rbx, 0 ; loop counter value
	calculateGrossProfitLoop:
		mov eax, dword[incomes + rbx * 4]
		sub eax, dword[expenses + rbx * 4]
		mov r8d, dword[customers + rbx * 4]
		
		cdq ; extend instruction
		idiv r8d ; signed division
		mov dword[grossProfitsPerCustomer + rbx * 4], eax

		inc rbx
	loop calculateGrossProfitLoop


endProgram:
; 	Ends program with success return value
	mov rax, programEnd
	mov rdi, finish
	syscall