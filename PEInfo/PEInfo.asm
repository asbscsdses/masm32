.386
.model flat,stdcall
option casemap:none

include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		comdlg32.inc
includelib	comdlg32.lib

				.data?
hInstance		dd		?
hRichEdit		dd		?
hWinMain		dd		?
hWinEdit		dd		?
szFileName		db		MAX_PATH dup (?)

				.const
szDllEdit		db		'RichEd20.dll',0
szClassEdit		db		'RichEdit20A',0
szFont			db		'宋体',0
szExtPe			db		'PE Files',0,'*.exe;*.dll;*.scr;*.fon;*.drv',0
				db		'All Files(*.*)',0,'*.*',0,0
szErr			db		'文件格式错误!',0
szErrFormat		db		'这个文件不是PE格式的文件!',0

				.code
_AppendInfo		proc	_lpsz
				local	@stCR:CHARRANGE
				
				pushad
				invoke	GetWindowTextLength,hWinEdit
				mov		@stCR.cpMin,eax
				mov		@stCR.cpMax,eax
				invoke	SendMessage,hWinEdit,EM_EXSETSEL,0,addr @stCR
				invoke	SendMessage,hWinEdit,EM_REPLACESEL,FALSE,_lpsz
				popad
				ret
_AppendInfo		endp

_Init			proc
				local	@stCf:CHARFORMAT
				
				invoke	GetDlgItem,hWinMain,IDC_INFO
				mov		hWinEdit,eax
				invoke	LoadIcon,hInstance,ICO_MAIN
				invoke	SendMessage,hWinMain,WM_SETICON,ICON_BIG,eax
				invoke	SendMessage,hWinEdit,EM_SETTEXTMODE,TM_PLAINTEXT,0
				invoke	RtlZeroMemory,addr @stCf,sizeof @stCf
				mov		@stCf.cbSize,sizeof @stCf
				mov		@stCf.yHeight,9*20
				mov		@stCf.dwMask,CFM_FACE or CFM_SIZE or CFM_BOLD
				invoke	lstrcpy,addr @stCf.szFaceName,addr szFont
				invoke	SendMessage,hWinEdit,EM_SETCHARFORMAT,0,addr @stCf
				invoke	SendMessage,hWinEdit,EM_EXLIMITTEXT,0,-1
				ret				
_Init			endp

_Handler		proc	C	_lpExceptionRecord,_lpSEH,\
							_lpContext,_lpDispatcherContext
							
				pushad
				mov		esi,_lpExceptionRecord
				mov		edi,_lpContext
				assume	esi:ptr	EXCEPTION_RECORT,edi:ptr CONTEXT
				mov		eax,_lpSEH
				push	[eax+0ch]
				pop		[edi].regEbp
				push	[eax+8]
				pop		[edi].regEip
				push	eax
				pop		[edi].regEsp
				assume	esi:nothing,edi:nothing
				popad
				mov		eax,ExceptionContinueExecution
				ret
_Handler		endp

_OpenFile		proc
				local	@stOF:OPENFILENAME
				local	@hFile,@dwFileSize,@hMapFile,@lpMemory
				
				invoke	RtlZeroMemory,addr @stOF,sizeof @stOF
				mov		@stOF.lStructSize,sizeof @stOF
				push	hWinMain
				pop		@stOF.hwndOwner
				mov		@stOF.lpstrFilter,offset szExtPe
				mov		@stOF.lpstrFile,offset szFileName
				mov		@stOF.nMaxFile,MAX_PATH
				mov		@stOF.Flags,OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST
				invoke	GetOpenFileName,addr @stOF
				.if		!eax
						jmp @F
				.endif
				invoke	CreateFile,addr szFileName,GENERIC_READ,\
							FILE_SHARE_READ or FILE_SHARE_WRITE,NULL,\
							OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,NULL
				.if		eax != INVALID_HANDLE_VALUE
						mov		@hFile,eax
						invoke	GetFileSize,eax,NULL
						mov		@dwFileSize,eax
						.if		eax
								invoke	CreateFileMapping,@hFile,\
											NULL,PAGE_READONLY,0,0,NULL
								.if		eax
										mov		@hMapFile,eax
										invoke	MapViewOfFile,eax,\
													FILE_MAP_READ,0,0,0