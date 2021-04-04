.cpu _45gs02
#import "../_include/m65macros.s"

.label SCREEN_RAM = $10000
// .label COLOR_RAM = $1f800
.label COLOR_RAM = $ff80000
.label NUMBER_OF_ROWS = $30

* = $02 "Zeropage" virtual
ZP: {
	SCREEN: .dword $00000000
}


BasicUpstart65(Entry)
* = $2016

Entry: {

		jsr SetupM65System
		jsr SetupVIC


		jsr ImportPalette

		lda #$00	//Char index LSB
		ldx #$02	//Char index MSB
		jsr ClearScreen16bit

		lda #$00
		jsr ClearColorRam

		lda #$10
		sta $d016

		//D054 = Full color char modes
		//bit 0 = 16bit char indices
		//bit 1 = FCM for chars <=$ff
		//bit 2 = FCM for chars > $ff
		lda #%00000111
		tsb $d054
	!:	
		jmp !-
}


ClearScreen16bit: {
		sta LSB
		stx MSB

		lda #<SCREEN_RAM
		sta ZP.SCREEN + 0
		lda #>SCREEN_RAM
		sta ZP.SCREEN + 1
		lda #[[SCREEN_RAM >> 16] & $ff]
		sta ZP.SCREEN + 2
		lda #$00
		sta ZP.SCREEN + 3

		ldy #$19
	!Loop:
		ldz #$00
	!:
		lda LSB:#$00
		sta ((ZP.SCREEN)), z
		inz
		lda MSB:#$00
		sta ((ZP.SCREEN)), z
		inz 
		cpz #$50	//Size of a row in bytes
		bne !-

		clc 
		lda ZP.SCREEN + 0 
		adc #$50   //Size of a row in bytes
		sta ZP.SCREEN + 0 
		bcc !+
		inw ZP.SCREEN + 1
	!:


		dey 
		bne !Loop-
		rts
}


/*
	//increment a 32 bit value by 1 (VALUE + 0-3)

		inq VALUE + 0
		bne !+
		inw VALUE + 2
	!:
*/

ClearScreen: {
		sta ClearScreenJob + 9 //This is the fill byte
		RunDMAJob(ClearScreenJob)
		rts

	ClearScreenJob:
		DMAHeader(0, SCREEN_RAM>>20) 
		DMAFillJob($01, SCREEN_RAM, 40 * NUMBER_OF_ROWS * 2, false)
}


ClearColorRam: {
		sta ClearColorRamJob + 9	
		RunDMAJob(ClearColorRamJob)
		rts

	ClearColorRamJob:
		DMAHeader($00, COLOR_RAM>>20 )
		DMAFillJob($01, COLOR_RAM, 40 * NUMBER_OF_ROWS * 2, false)
}




SetupVIC: {
		//relocate screen
		lda #<SCREEN_RAM  //LSB #<
		sta $d060
		lda #>SCREEN_RAM  //MSB #>
		sta $d061
		lda #[[SCREEN_RAM >> 16] & $ff] //24bit MSB
		sta $d062

		//40 column mode (clear bit 7 of D031)
		lda #$80
		trb $d031 

		//Reposition start of top border
		// lda #$00
		// sta $d048
		// //Reposition start of bottom border
		// lda #$20
		// sta $d04a
		// lda #$02
		// sta $d04b

		// //Reposition start of screen at top
		// lda #$10
		// sta $d04e



		rts
}


SetupM65System: {
		sei 
		
		// Set memory layout (c64??)
		lda #$35
		sta $01
		
		enable40Mhz() 
		enableVIC4Registers()

		//Disable hot register so VIC2 registers 
		//turn off bit 7 
		lda #$80		
		trb $d05d		//wont destroy VIC4 values (bit 7)

		// Turn off CIA interrupts
		lda #$7f
		sta $dc0d
		sta $dd0d
		
		//Turn off raster interrupts, used by C65 rom
		lda #$00
		sta $d01a
        cli
        rts
}

ImportPalette: {
		//Bit 6-7 = Mapped Palette
		//bit 0-1 = Char palette index
		lda #%01000001
		sta $d070

		ldx #$00
	!:
		lda PaletteData + $000, x
		sta $d100, x //Red
		lda PaletteData + $100, x
		sta $d200, x //Green
		lda PaletteData + $200, x
		sta $d300, x //Blue
		inx
		bne !-

		rts
}

* = $7000
PaletteData:
	.import binary "pal.bin"

* = $8000	///Char index = $0200	
	.import binary "chars.bin"

