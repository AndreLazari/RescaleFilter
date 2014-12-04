INCLUDE Irvine32.inc


.data

imagem_entrada BYTE "Flower.pnm", 0 ; Imagem de entrada
buffer BYTE 500000 dup(?)

imagem_saida BYTE "nova_imagem.pnm", 0
legenda BYTE "Insira o fator de brilho da imagem entre 2 e 10", 0dh, 0ah, "10 representa o brilho maximo e 2 o minimo", 0

soma WORD ?
file_handle DWORD ?

tamanho_img DWORD ?
tamanho_cabecalho BYTE 0

fator  DWORD ?

.code

Ler_fator PROC

 mov edx, offset legenda
 call WriteString
 call Crlf
     

 Trata_erro_fator: ; Verifica se o fator inserido está no intervalo [2,10] caso contrário deve ser inserido novamente

 call ReadInt  ; Ler o fator

 cmp eax, 2
 jb Trata_erro_fator

 cmp eax, 100
 jnb Trata_erro_fator

 mov fator , eax ; Define o fator

 ret

Ler_fator ENDP


; Função para ler o cabeçalho do arquivo e contar o número de bytes do mesmo
Ler_cabecalho PROC 

 mov eax, file_handle
 mov esi, offset buffer
 add esi, 3 
 mov  ebx, 0
 cabecalho:
    
  mov dl, [esi]
  cmp dl, 0ah
  je continua
  inc esi
  inc ebx
  jmp cabecalho

  continua:
  add bl, 5 ; Soma a contagem os caracteres "P6" mais as quebras de linhas
  mov tamanho_cabecalho, bl
  ret

Ler_cabecalho ENDP


Processamento_filtro PROC

  inc esi
  mov edi, esi
  
  mov ecx, tamanho_img
  sub cl, tamanho_cabecalho

  L1:
  
  mov eax, 0
  mov al, [esi]
  mul fator

  cmp eax, 255
  jnb maximo
  mov [edi], al
  jmp prox

  maximo: 
  mov eax, 255
  mov [edi], al

  prox:
  inc edi
  inc esi

  loop L1
  ret

Processamento_filtro ENDP

main PROC
   
   call Ler_fator

   mov edx, offset imagem_entrada
   call OpenInputFile

   mov edx, offset buffer
   mov ecx, lengthof buffer
   call ReadFromFile

   mov tamanho_img, eax
   mov edx, offset imagem_saida
   call CreateOutputFile
   mov file_handle, eax

  call Ler_cabecalho ; Chama a leitura de cabeçalho

  call Processamento_filtro ; Chama a função principal que aplica o filtro à imagem
  
  ; Escreve a nova imagem no arquivo
  mov edx, offset buffer
  mov ecx, tamanho_img
  mov eax, file_handle

  call WriteToFile

  call CloseFile
  exit    

main ENDP

END main
