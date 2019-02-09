!
!	8080 cpmsim loads the first (128 byte) sector from the disk into memory
!	at 0 then executes it.	We are a bit tight on space here especially
!	in 8080
!
!	Floppy loader: 
!	Our boot disc is 77 tracks of 26 x 128 byte sectors, and we put
!	the OS on tracks 58+, which means we can put a file system in the
!	usual place providing its a bit smaller than a whole disc.
!
!
!	assemble with ack 8080
!

!	Keep aslod happy

		.sect .text
		.sect .data
		.sect .bss
		.sect .rom
		.sect .text


console = 1
drive = 10
track = 11
sector = 12
command = 13
status = 14
dmal = 15
dmah = 16
sectorh = 17

diskload:	di
		xra a
		out sectorh		! sector high always 0
		out drive		! drive always 0
		mvi a,57		! start on track 58
		out track
		mvi c,19		! number of tracks to load (56Kish)

		lxi d,128

load_tracks:	in track
		inr a			! next track
		out track
		xra a			! sector 0 (first will be 1)
		out sector
		mvi b,26		! sectors per track
load_sectors:	
		in sector
		inr a
		out sector		! next sector
		mov a, l
		out dmal		! dma low
		mov a, h
		out dmah		! dma high
		xra a			! read
		out command		! go
		in status		! status
		dad d
		dcr b
		jnz load_sectors	! 26 sectors = 3328 bytes
		dcr c
		jnz load_tracks
		mvi a, 13
		out 1
		mvi a,10
		out 1
		jmp 0x88
