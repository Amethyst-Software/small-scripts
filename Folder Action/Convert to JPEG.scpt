FasdUAS 1.101.10   ��   ��    k             l      ��  ��    � �
Convert AVIF, PNG, WebP and BMP images to JPEG when added to a folder which this action is attached to.  Requires ImageMagick to be installed.
     � 	 	  
 C o n v e r t   A V I F ,   P N G ,   W e b P   a n d   B M P   i m a g e s   t o   J P E G   w h e n   a d d e d   t o   a   f o l d e r   w h i c h   t h i s   a c t i o n   i s   a t t a c h e d   t o .     R e q u i r e s   I m a g e M a g i c k   t o   b e   i n s t a l l e d . 
   
  
 l     ��������  ��  ��        l     ��������  ��  ��     ��  i         I     ��  
�� .facofgetnull���     alis  o      ���� 0 this_folder    �� ��
�� 
flst  o      ���� 0 added_items  ��    Q     �  ��  O    �    X    � ��   Z    �  ����  G    :    G    0    G    &   !   =    " # " l    $���� $ n     % & % 1    ��
�� 
kind & o    ���� 0 	this_item  ��  ��   # l 	   '���� ' m     ( ( � ) ) * A V 1   I m a g e   F i l e   F o r m a t��  ��   ! =   $ * + * l   " ,���� , n    " - . - 1     "��
�� 
kind . o     ���� 0 	this_item  ��  ��   + l 	 " # /���� / m   " # 0 0 � 1 1  P N G   i m a g e��  ��    =  ) . 2 3 2 l  ) , 4���� 4 n   ) , 5 6 5 1   * ,��
�� 
kind 6 o   ) *���� 0 	this_item  ��  ��   3 l 	 , - 7���� 7 m   , - 8 8 � 9 9  W e b P   I m a g e��  ��    =  3 8 : ; : l  3 6 <���� < n   3 6 = > = 1   4 6��
�� 
kind > o   3 4���� 0 	this_item  ��  ��   ; l 	 6 7 ?���� ? m   6 7 @ @ � A A " W i n d o w s   B M P   i m a g e��  ��    k   = � B B  C D C r   = B E F E l  = @ G���� G n   = @ H I H 1   > @��
�� 
psxp I o   = >���� 0 	this_item  ��  ��   F o      ����  0 this_item_unix this_item_Unix D  J K J r   C L L M L I  C J�� N��
�� .corecnte****       **** N n  C F O P O 2  D F��
�� 
cha  P o   C D����  0 this_item_unix this_item_Unix��   M o      ���� 0 this_item_char   K  Q R Q l  M M��������  ��  ��   R  S T S l  M M�� U V��   U T N Walk backward from end of file path until we find period denoting file suffix    V � W W �   W a l k   b a c k w a r d   f r o m   e n d   o f   f i l e   p a t h   u n t i l   w e   f i n d   p e r i o d   d e n o t i n g   f i l e   s u f f i x T  X Y X r   M P Z [ Z o   M N���� 0 this_item_char   [ o      ���� 0 char_itr   Y  \ ] \ r   Q T ^ _ ^ m   Q R����   _ o      ���� 0 last_period   ]  ` a ` V   U ~ b c b k   ] y d d  e f e r   ] c g h g n   ] a i j i 4   ^ a�� k
�� 
cha  k o   _ `���� 0 char_itr   j o   ] ^����  0 this_item_unix this_item_Unix h o      ���� 0 	this_char   f  l m l Z   d s n o���� n l  d g p���� p =  d g q r q o   d e���� 0 	this_char   r m   e f s s � t t  .��  ��   o k   j o u u  v w v r   j m x y x o   j k���� 0 char_itr   y o      ���� 0 last_period   w  z�� z  S   n o��  ��  ��   m  {�� { r   t y | } | l  t w ~���� ~ \   t w  �  o   t u���� 0 char_itr   � m   u v���� ��  ��   } o      ���� 0 char_itr  ��   c l  Y \ ����� � ?   Y \ � � � o   Y Z���� 0 char_itr   � m   Z [����  ��  ��   a  � � � l   ��������  ��  ��   �  � � � l   �� � ���   � O I Prepare JPEG version of file's name and tell ImageMagick to convert file    � � � � �   P r e p a r e   J P E G   v e r s i o n   o f   f i l e ' s   n a m e   a n d   t e l l   I m a g e M a g i c k   t o   c o n v e r t   f i l e �  � � � r    � � � � b    � � � � l   � ����� � c    � � � � n    � � � � 7  � ��� � �
�� 
cha  � m   � �����  � l  � � ����� � \   � � � � � o   � ����� 0 last_period   � m   � ����� ��  ��   � o    �����  0 this_item_unix this_item_Unix � m   � ���
�� 
TEXT��  ��   � m   � � � � � � �  . j p g � o      ����  0 this_item_jpeg this_item_JPEG �  � � � r   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � m   � � � � � � � 0 / o p t / l o c a l / b i n / c o n v e r t   " � o   � �����  0 this_item_unix this_item_Unix � m   � � � � � � �  "   " � o   � �����  0 this_item_jpeg this_item_JPEG � m   � � � � � � �  " � o      ���� 0 
convertcmd 
convertCmd �  ��� � I  � ��� ���
�� .sysoexecTEXT���     TEXT � o   � ����� 0 
convertcmd 
convertCmd��  ��  ��  ��  �� 0 	this_item    o   
 ���� 0 added_items    m     � ��                                                                                  MACS  alis    @  Macintosh HD               ���BD ����
Finder.app                                                     �������        ����  
 cu             CoreServices  )/:System:Library:CoreServices:Finder.app/    
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��    R      ������
�� .ascrerr ****      � ****��  ��  ��  ��       �� � ���   � ��
�� .facofgetnull���     alis � �� ���� � ���
�� .facofgetnull���     alis�� 0 this_folder  �� ������
�� 
flst�� 0 added_items  ��   � 
���������������������� 0 this_folder  �� 0 added_items  �� 0 	this_item  ��  0 this_item_unix this_item_Unix�� 0 this_item_char  �� 0 char_itr  �� 0 last_period  �� 0 	this_char  ��  0 this_item_jpeg this_item_JPEG�� 0 
convertcmd 
convertCmd �  �����~�} ( 0�| 8 @�{�z s�y � � � ��x�w�v
�� 
kocl
� 
cobj
�~ .corecnte****       ****
�} 
kind
�| 
bool
�{ 
psxp
�z 
cha 
�y 
TEXT
�x .sysoexecTEXT���     TEXT�w  �v  �� � �� � ��[��l kh ��,� 
 	��,� �&
 	��,� �&
 	��,� �& p��,E�O��-j E�O�E�OjE�O (h�j��/E�O��  
�E�OY hO�kE�[OY��O�[�\[Zk\Z�k2�&�%E�O�%a %�%a %E�O�j Y h[OY�eUW X  hascr  ��ޭ