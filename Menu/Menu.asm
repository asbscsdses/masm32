.386
.model flat,stdcall
option casemap:none

include 	windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib


IDR_MENU1          equ        101
IDR_ACCELERATOR1   equ        102
IDI_ICON1          equ        103
IDM_OPEN           equ        40004
IDM_OPTION         equ        40005
IDM_EXIT           equ        40006
IDM_SETFONT        equ        40008
IDM_SETCOLOR       equ        40010
IDM_INACT          equ        40012
IDM_GRAYED         equ        40014
IDM_BIG            equ        40016
IDM_SMALL          equ        40018
IDM_LIST           equ        40020
IDM_DETAIL         equ        40022
IDM_TOOLBAR        equ        40025
IDM_TOOLBARTEXT    equ        40027
IDM_INPUTBAR       equ        40029
IDM_STATUSBAR      equ        40031
IDM_HELP           equ        40033
IDM_ABOUT          equ        40035

				.data?
hInstance		dd		?
hWinMain		dd		?
hMenu			dd		?
hSubMenu		dd		?
				.const
szClassName		db		'Menu Example',0
szCaptionMain	db		'Menu',0
szMenuHelp		db		'帮助主题(&H)',0
szMenuAbout		db		'关于本程序(&A)...',0
szCaption		db		'菜单选择',0
szFormat		db		'您选择了菜单命令: %08x',0

				.code
_DisplayMenuItem 		proc 		_dwCommandId
						local		@szBuffer[256]:byte
				
				pushad
				invoke	wsprintf,addr @szBuffer,addr szFormat,_dwCommandId
				invoke	MessageBox,hWinMain,addr @szBuffer,\
							offset szCaption,MB_OK
				popad
				ret
_DisplayMenuItem		endp

_Quit					proc
				invoke	DestroyWindow,hWinMain
				invoke	PostQuitMessage,NULL
				ret
_Quit					endp

_ProcWinMain			proc		uses ebx edi esi hWnd,uMsg,wParam,lParam
						local		@stPos:POINT
						local		@hSysMenu
						
				mov		eax,uMsg
				.if		eax == WM_CREATE
						invoke GetSubMenu,hMenu,1
						mov		hSubMenu,eax
						;在系统菜单中添加菜单项
						invoke	GetSystemMenu,hWnd,FALSE
						mov		@hSysMenu,eax
						invoke	AppendMenu,@hSysMenu,MF_SEPARATOR,0,NULL
						invoke	AppendMenu,@hSysMenu,\
									0,IDM_HELP,offset szMenuHelp
						invoke	AppendMenu,@hSysMenu,\
									0,IDM_ABOUT,offset szMenuAbout
						;处理菜单及加速键消息
				.elseif	eax == WM_COMMAND
						invoke	_DisplayMenuItem,wParam
						mov		eax,wParam
						movzx	eax,ax
						.if		eax == IDM_EXIT
								call _Quit
						.elseif	eax >= IDM_TOOLBAR && eax <= IDM_STATUSBAR
								mov		ebx,eax
								invoke	GetMenuState,hMenu,ebx,MF_BYCOMMAND
								.if		eax == MF_CHECKED
										mov		eax,MF_UNCHECKED
								.else
										mov 	eax,MF_CHECKED
								.endif
								invoke	CheckMenuItem,hMenu,ebx,eax
						.elseif	eax >= IDM_BIG && eax <= IDM_DETAIL
								invoke	CheckMenuRadioItem,hMenu,IDM_BIG,\
											IDM_DETAIL,eax,MF_BYCOMMAND
						.endif
						;处理系统菜单消息
				.elseif	eax == WM_SYSCOMMAND
						mov		eax,wParam
						movzx	eax,ax
						.if 	eax == IDM_HELP || eax == IDM_ABOUT
								invoke _DisplayMenuItem,wParam
						.else
								invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
								ret
						.endif
						;右键时弹出菜单
				.elseif eax == WM_RBUTTONDOWN
						invoke	GetCursorPos,addr @stPos
						invoke	TrackPopupMenu,hSubMenu,TPM_LEFTALIGN,\
									@stPos.x,@stPos.y,NULL,hWnd,NULL
				.elseif	eax == WM_CLOSE
						call	_Quit
				.else
						invoke	DefWindowProc,hWnd,uMsg,wParam,lParam
						ret
				.endif
				xor		eax,eax
				ret
_ProcWinMain			endp

_WinMain				proc
						local	@stWndClass:WNDCLASSEX
						local	@stMSG:MSG
						local	@hAccelerator
						
						invoke	GetModuleHandle,NULL
						mov		hInstance,eax
						invoke	LoadMenu,hInstance,IDR_MENU1
						mov		hMenu,eax
						invoke	LoadAccelerators,hInstance,IDR_ACCELERATOR1
						mov		@hAccelerator,eax
						
						;注册窗口类
						invoke	RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
						invoke	LoadIcon,hInstance,IDI_ICON1
						mov		@stWndClass.hIcon,eax
						mov		@stWndClass.hIconSm,eax
						push	hInstance
						pop		@stWndClass.hInstance
						mov		@stWndClass.cbSize,sizeof WNDCLASSEX
						mov		@stWndClass.style,CS_HREDRAW or CS_VREDRAW
						mov		@stWndClass.lpfnWndProc,offset _ProcWinMain
						mov		@stWndClass.hbrBackground,COLOR_WINDOW+1
						mov		@stWndClass.lpszClassName,offset szClassName
						invoke	RegisterClassEx,addr @stWndClass
						
						;建立并显示窗口
						invoke  CreateWindowEx,WS_EX_CLIENTEDGE,\
									offset szClassName,offset szCaptionMain,\
									WS_OVERLAPPEDWINDOW,\
									100,100,400,300,\
									NULL,hMenu,hInstance,NULL
						mov 	hWinMain,eax
						invoke	ShowWindow,hWinMain,SW_SHOWNORMAL
						invoke	UpdateWindow,hWinMain
						
						;消息循环
						.while	TRUE
								invoke	GetMessage,addr @stMSG,NULL,0,0
								.break	.if	eax == 0
								invoke	TranslateAccelerator,hWinMain,\
											@hAccelerator,addr @stMSG
								.if		eax == 0
										invoke	TranslateMessage,addr @stMSG
										invoke	DispatchMessage,addr @stMSG
								.endif
						.endw
						ret
						
_WinMain				endp

start:
						call	_WinMain
						invoke	ExitProcess,NULL
						
						end		start