@ ********************************************************
@ Author: Hoon Chung
@ Class & section:  CS 2301 section 1
@ Date: 04/26/2017    
@ File:	HW06.s
@ Version: 1
@ ********************************************************
	.equ 	SWI_CheckBlack,	0x202	@ check Black button
	.equ 	SWI_DrawString,	0x204	@ display a string on LCD
	.equ 	SWI_DrawInt,	0x205   @ display an int on LCD
	.equ 	SWI_ClearDisplay,0x206  @ clear LCD
	.equ 	SWI_DrawChar,	0x207   @ display a char on LCD
	.equ	SWI_GetTicks,0x6d  		@ Get current time.
	.equ	SWI_Exit,0x11 			@ Halt execution.
	.equ	leftBB,	0x02 			@ left black button
	.equ	rightBB, 0x01			@ right black button

	.DATA
	@ Variables
location: .word 7
shield: .word 3
numAsteroids: .word 5
asteroids:
	.word 	20, 3,  24, 12,  28, 6,  32, 2,  36, 9
	.skip	800

	@ Constants
	.equ shipChar1, 40
	.equ shipChar2, 62
	.equ asteroidChar, 42
	.equ levelTime, 8192
msgLevel: .asciz "Level:"
msgShield: .asciz "Shield:"
msgCollision: .asciz "Collision!"
msgGameOver: .asciz "GAME OVER"

	.TEXT
start:
	swi		SWI_GetTicks
	add		r4, r0, #levelTime
mainLoop:
	bl		displayGame
	mov		r0, #50
	bl		timer
	bl		detectCollision
	bl		controlShip
	bl		updateAsteroids
	swi		SWI_GetTicks
	cmp		r0, r4
	addgt	r4, r0, #levelTime
	blgt	increaseLevel
	b		mainLoop

@====================================
@ Subroutine displayGame
@
@ Parameters:
@   Nothing
@
@ Return:
@   Nothing
@
@ Registers r4-r12 used: r4
@====================================
displayGame:
	stmfd	sp!, {lr, r4}			@ save return address
	
	swi SWI_ClearDisplay
	mov r1, #20					@row
	mov r0, #0					@column
	mov r2, #'>'
	swi SWI_DrawChar			@display the ship

	ldr r4, =asteroid
	ldr r0, [r4]				@r0 = x
	mov r2, #'*'
	b asteroidIter

asteroidIter:
	cmp r0, #0 
	beq displayLevel
	add r4, r4, #4
	ldr r1, [r4]				@r1 = y (row)
	swi SWI_DrawChar
	add r4, r4, #4
	ldr r0, [r4]
	b asteroidIter

displayLevel:
	ldr r4, =msgLevel	
	ldr r2, [r4]
	mov r0, #33				
	mov r1,	#14
	swi SWI_DrawString
	ldr r4, =numAsteroids
	ldrb r2, [r4]			
	sub r2, r2, #4				@get game level and is display
	mov r0, #40
	mov r1, #14
	swi SWI_DrawChar
	b displayShield

displayShield:
	ldr r4, =msgShield
	ldr r2, [r4]
	mov r0, #32
	mov r1, #0
	swi SWI_DrawString				@display current shield level
	ldr r4, =shield
	ldrb r2, [r4]
	swi SWI_DrawChar
	b displayGameExit

displayGameExit:
	ldmfd	sp!, {lr, r4}			@ restore
	mov		pc, lr					@ return

@====================================
@ Subroutine controlShip
@
@ Parameters:
@   Nothing
@
@ Return:
@   Nothing
@
@ Registers r4-r12 used: 
@====================================
controlShip:
	stmfd	sp!, {lr}			@ save return address
	ldmfd	sp!, {lr}			@ restore
	mov		pc, lr				@ return
	
@====================================
@ Subroutine updateAsteroids
@
@ Parameters:
@   Nothing
@
@ Return:
@   Nothing
@
@ Registers r4-r12 used: 
@====================================
updateAsteroids:
	stmfd	sp!, {lr}			@ save return address
	ldmfd	sp!, {lr}			@ restore
	mov		pc, lr				@ return
	
@====================================
@ Subroutine initAsteroid
@
@ Parameters:
@   r0: address of asteroid to initialize
@
@ Return:
@   Nothing
@
@ Registers r4-r12 used: 
@====================================
initAsteroid:
	stmfd	sp!, {lr, r4}		@ save return address
	@ replace the following code
	mov		r4, #36
	str		r4, [r0]
	mov		r4, #0
	str		r4, [r0, #4]
	ldmfd	sp!, {lr, r4}		@ restore
	mov		pc, lr				@ return

@====================================
@ Subroutine detectCollision
@
@ Parameters:
@   Nothing
@
@ Return:
@   Nothing
@
@ Registers r4-r12 used: 
@====================================
detectCollision:
	stmfd	sp!, {lr}			@ save return address
	ldmfd	sp!, {lr}			@ restore
	mov		pc, lr				@ return

@====================================
@ Subroutine increaseLevel
@
@ Parameters:
@   Nothing
@
@ Return:
@   Nothing
@
@ Registers r4-r12 used: 
@====================================
increaseLevel:
	stmfd	sp!, {lr}			@ save return address
	ldmfd	sp!, {lr}			@ restore
	mov		pc, lr				@ return

@==========================================
@ Subroutine timer:
@ Wait for x milliseconds 
@
@ Parameters:
@   r0 : number of ms to wait
@
@ Return:
@   nothing
@
@ Registers r4-r12 used: 
@==========================================
timer:
	stmfd sp!, {r4-r5, lr}
	mov r4, r0
	swi SWI_GetTicks
	add r5, r4 ,r0
	b timerLoop

timerLoop:
	swi SWI_GetTicks
	cmp r5,r0
	BLE timerExit
	b timerLoop

timerExit:
	ldmfd sp!, {r4-r5}	
	mov pc, lr
	.END
