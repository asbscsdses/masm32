.386
.model flat,stdcall
option casemap:none

include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib

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
				invoke	MessageBox,NULL,addr @szBuffer,\
				;invoke	MessageBox,NULL,offset szMenuAbout,
							offset szCaption,MB_OK
				popad
				ret
_DisplayMenuItem		endp	
		
start:
			mov eax,1
			invoke _DisplayMenuItem,eax
			invoke 	ExitProcess,NULL
			
			end		start