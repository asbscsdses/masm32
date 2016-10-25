.386
.model flat,stdcall
option casemap:none

include			windows.inc
include			user32.inc
includelib		user32.lib
include			kernel32.inc
includelib		kernel32.lib
				
IDD_DIALOG1		equ				101
IDI_ICON1		equ				103
								
				.data?   		
hInstance		dd				?
								
				.code    		
_ProcDlgMain	proc	uses ebx edi esi hWnd,wMsg,wParam,lParam
				mov		eax,wMsg
				.if		eax == WM_CLOSE
						invoke EndDialog,hWnd,NULL
				.elseif	eax == WM_INITDIALOG
						invoke	LoadIcon,hInstance, IDI_ICON1
						invoke	SendMessage,hWnd,WM_SETICON,ICON_BIG,eax
				.elseif	eax == WM_COMMAND
						mov		eax,wParam
						.if		ax == IDOK
								invoke	EndDialog,hWnd,NULL
						.endif
				.else
						mov		eax,FALSE
						ret
				.endif
				mov		eax,TRUE
				ret
_ProcDlgMain	endp

Start:
				invoke	GetModuleHandle,NULL
				mov		hInstance,eax
				invoke	DialogBoxParam,hInstance,IDD_DIALOG1,\
							NULL,offset _ProcDlgMain,NULL
				invoke	ExitProcess,NULL
				end		Start
				