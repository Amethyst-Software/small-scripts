FasdUAS 1.101.10   ��   ��    k             l      ��  ��    �
Convert to MP4A video dropped onto an applet saved with this script will be passed through ffmpeg and convertedto an H.264 MP4. The script will then apply the original file's modification date to the converted one.
Requires ffmpeg to be installed.
     � 	 	� 
 C o n v e r t   t o   M P 4  A   v i d e o   d r o p p e d   o n t o   a n   a p p l e t   s a v e d   w i t h   t h i s   s c r i p t   w i l l   b e   p a s s e d   t h r o u g h   f f m p e g   a n d   c o n v e r t e d  t o   a n   H . 2 6 4   M P 4 .   T h e   s c r i p t   w i l l   t h e n   a p p l y   t h e   o r i g i n a l   f i l e ' s   m o d i f i c a t i o n   d a t e   t o   t h e   c o n v e r t e d   o n e . 
 R e q u i r e s   f f m p e g   t o   b e   i n s t a l l e d . 
   
  
 l     ��������  ��  ��     ��  i         I     �� ��
�� .aevtodocnull  �    alis  o      ���� 0 these_items  ��    Y     � ��  ��  O    �    k    �       r        n        4    �� 
�� 
cobj  o    ���� 0 i    o    ���� 0 these_items    o      ���� 0 	this_item        r         l    !���� ! n     " # " 1    ��
�� 
psxp # o    ���� 0 	this_item  ��  ��     o      ����  0 this_item_unix this_item_Unix   $ % $ r    ( & ' & I   &�� (��
�� .corecnte****       **** ( n   " ) * ) 2    "��
�� 
cha  * o     ����  0 this_item_unix this_item_Unix��   ' o      ���� 0 this_item_char   %  + , + l  ) )��������  ��  ��   ,  - . - l  ) )�� / 0��   / T N Walk backward from end of file path until we find period denoting file suffix    0 � 1 1 �   W a l k   b a c k w a r d   f r o m   e n d   o f   f i l e   p a t h   u n t i l   w e   f i n d   p e r i o d   d e n o t i n g   f i l e   s u f f i x .  2 3 2 r   ) , 4 5 4 o   ) *���� 0 this_item_char   5 o      ���� 0 char_itr   3  6 7 6 r   - 0 8 9 8 m   - .����   9 o      ���� 0 last_period   7  : ; : V   1 Z < = < k   9 U > >  ? @ ? r   9 ? A B A n   9 = C D C 4   : =�� E
�� 
cha  E o   ; <���� 0 char_itr   D o   9 :����  0 this_item_unix this_item_Unix B o      ���� 0 	this_char   @  F G F Z   @ O H I���� H l  @ C J���� J =  @ C K L K o   @ A���� 0 	this_char   L m   A B M M � N N  .��  ��   I k   F K O O  P Q P r   F I R S R o   F G���� 0 char_itr   S o      ���� 0 last_period   Q  T�� T  S   J K��  ��  ��   G  U�� U r   P U V W V l  P S X���� X \   P S Y Z Y o   P Q���� 0 char_itr   Z m   Q R���� ��  ��   W o      ���� 0 char_itr  ��   = l  5 8 [���� [ ?   5 8 \ ] \ o   5 6���� 0 char_itr   ] m   6 7����  ��  ��   ;  ^ _ ^ l  [ [��������  ��  ��   _  ` a ` l  [ [�� b c��   b N H Prepare MP4 version of file's name and tell ImageMagick to convert file    c � d d �   P r e p a r e   M P 4   v e r s i o n   o f   f i l e ' s   n a m e   a n d   t e l l   I m a g e M a g i c k   t o   c o n v e r t   f i l e a  e f e r   [ n g h g b   [ l i j i l  [ j k���� k c   [ j l m l n   [ h n o n 7  \ h�� p q
�� 
cha  p m   ` b����  q l  c g r���� r \   c g s t s o   d e���� 0 last_period   t m   e f���� ��  ��   o o   [ \����  0 this_item_unix this_item_Unix m m   h i��
�� 
TEXT��  ��   j m   j k u u � v v  . m p 4 h o      ���� 0 this_item_mp4 this_item_MP4 f  w x w Z   o � y z���� y =  o t { | { n   o r } ~ } 1   p r��
�� 
nmxt ~ o   o p���� 0 	this_item   | m   r s   � � �  m p 4 z r   w � � � � b   w � � � � l  w � ����� � c   w � � � � n   w � � � � 7  x ��� � �
�� 
cha  � m   | ~����  � l   � ����� � \    � � � � o   � ����� 0 last_period   � m   � ����� ��  ��   � o   w x����  0 this_item_unix this_item_Unix � m   � ���
�� 
TEXT��  ��   � m   � � � � � � �    2 . m p 4 � o      ���� 0 this_item_mp4 this_item_MP4��  ��   x  � � � r   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � m   � � � � � � � 4 / o p t / l o c a l / b i n / f f m p e g   - i   " � o   � �����  0 this_item_unix this_item_Unix � m   � � � � � � �  "   " � o   � ����� 0 this_item_mp4 this_item_MP4 � m   � � � � � � �  " � o      ���� 0 
convertcmd 
convertCmd �  � � � I  � ��� ���
�� .sysoexecTEXT���     TEXT � o   � ����� 0 
convertcmd 
convertCmd��   �  � � � r   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � m   � � � � � � �  t o u c h   - r   " � o   � �����  0 this_item_unix this_item_Unix � m   � � � � � � �  "   " � o   � ����� 0 this_item_mp4 this_item_MP4 � m   � � � � � � �  " � o      ���� 0 touchcmd touchCmd �  ��� � I  � ��� ���
�� .sysoexecTEXT���     TEXT � o   � ����� 0 touchcmd touchCmd��  ��    m     � ��                                                                                  MACS  alis    @  Macintosh HD               �+%�BD ����
Finder.app                                                     �����+%�        ����  
 cu             CoreServices  )/:System:Library:CoreServices:Finder.app/    
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��  �� 0 i    m    ����   l   	 ����� � I   	�� ���
�� .corecnte****       **** � o    ���� 0 these_items  ��  ��  ��  ��  ��       �� � ���   � ��
�� .aevtodocnull  �    alis � �� ���� � ���
�� .aevtodocnull  �    alis�� 0 these_items  ��   � ������������������������ 0 these_items  �� 0 i  �� 0 	this_item  ��  0 this_item_unix this_item_Unix�� 0 this_item_char  �� 0 char_itr  �� 0 last_period  �� 0 	this_char  �� 0 this_item_mp4 this_item_MP4�� 0 
convertcmd 
convertCmd�� 0 touchcmd touchCmd � �� ������� M�� u��  � � � ��� � � �
�� .corecnte****       ****
�� 
cobj
�� 
psxp
�� 
cha 
�� 
TEXT
�� 
nmxt
�� .sysoexecTEXT���     TEXT�� � �k�j  kh � ���/E�O��,E�O��-j  E�O�E�OjE�O (h�j��/E�O��  
�E�OY hO�kE�[OY��O�[�\[Zk\Z�k2�&�%E�O��,�  �[�\[Zk\Z�k2�&�%E�Y hO�%�%�%�%E�O�j O�%a %�%a %E�O�j U[OY�Qascr  ��ޭ