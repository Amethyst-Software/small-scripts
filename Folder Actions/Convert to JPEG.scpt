FasdUAS 1.101.10   ��   ��    k             l      ��  ��    � �
Convert PNG, WebP and BMP images to JPEG when added to a folder which this action is attached to.  Requires ImageMagick to be installed.
     � 	 	 
 C o n v e r t   P N G ,   W e b P   a n d   B M P   i m a g e s   t o   J P E G   w h e n   a d d e d   t o   a   f o l d e r   w h i c h   t h i s   a c t i o n   i s   a t t a c h e d   t o .     R e q u i r e s   I m a g e M a g i c k   t o   b e   i n s t a l l e d . 
   
  
 l     ��������  ��  ��        l     ��������  ��  ��     ��  i         I     ��  
�� .facofgetnull���     alis  o      ���� 0 this_folder    �� ��
�� 
flst  o      ���� 0 added_items  ��    Q     �  ��  O    �    X    � ��   Z    �  ����  G    0    G    &    =      !   l    "���� " n     # $ # 1    ��
�� 
kind $ o    ���� 0 	this_item  ��  ��   ! l 	   %���� % m     & & � ' '  P N G   i m a g e��  ��    =   $ ( ) ( l   " *���� * n    " + , + 1     "��
�� 
kind , o     ���� 0 	this_item  ��  ��   ) l 	 " # -���� - m   " # . . � / /  W e b P   I m a g e��  ��    =  ) . 0 1 0 l  ) , 2���� 2 n   ) , 3 4 3 1   * ,��
�� 
kind 4 o   ) *���� 0 	this_item  ��  ��   1 l 	 , - 5���� 5 m   , - 6 6 � 7 7 " W i n d o w s   B M P   i m a g e��  ��    k   3 � 8 8  9 : 9 r   3 8 ; < ; l  3 6 =���� = n   3 6 > ? > 1   4 6��
�� 
psxp ? o   3 4���� 0 	this_item  ��  ��   < o      ����  0 this_item_unix this_item_Unix :  @ A @ r   9 B B C B I  9 @�� D��
�� .corecnte****       **** D n  9 < E F E 2  : <��
�� 
cha  F o   9 :����  0 this_item_unix this_item_Unix��   C o      ���� 0 this_item_char   A  G H G l  C C��������  ��  ��   H  I J I l  C C�� K L��   K T N Walk backward from end of file path until we find period denoting file suffix    L � M M �   W a l k   b a c k w a r d   f r o m   e n d   o f   f i l e   p a t h   u n t i l   w e   f i n d   p e r i o d   d e n o t i n g   f i l e   s u f f i x J  N O N r   C F P Q P o   C D���� 0 this_item_char   Q o      ���� 0 char_itr   O  R S R r   G J T U T m   G H����   U o      ���� 0 last_period   S  V W V V   K t X Y X k   S o Z Z  [ \ [ r   S Y ] ^ ] n   S W _ ` _ 4   T W�� a
�� 
cha  a o   U V���� 0 char_itr   ` o   S T����  0 this_item_unix this_item_Unix ^ o      ���� 0 	this_char   \  b c b Z   Z i d e���� d l  Z ] f���� f =  Z ] g h g o   Z [���� 0 	this_char   h m   [ \ i i � j j  .��  ��   e k   ` e k k  l m l r   ` c n o n o   ` a���� 0 char_itr   o o      ���� 0 last_period   m  p�� p  S   d e��  ��  ��   c  q�� q r   j o r s r l  j m t���� t \   j m u v u o   j k���� 0 char_itr   v m   k l���� ��  ��   s o      ���� 0 char_itr  ��   Y l  O R w���� w ?   O R x y x o   O P���� 0 char_itr   y m   P Q����  ��  ��   W  z { z l  u u��������  ��  ��   {  | } | l  u u�� ~ ��   ~ O I Prepare JPEG version of file's name and tell ImageMagick to convert file     � � � �   P r e p a r e   J P E G   v e r s i o n   o f   f i l e ' s   n a m e   a n d   t e l l   I m a g e M a g i c k   t o   c o n v e r t   f i l e }  � � � r   u � � � � b   u � � � � l  u � ����� � c   u � � � � n   u � � � � 7  v ��� � �
�� 
cha  � m   z |����  � l  } � ����� � \   } � � � � o   ~ ���� 0 last_period   � m    ����� ��  ��   � o   u v����  0 this_item_unix this_item_Unix � m   � ���
�� 
TEXT��  ��   � m   � � � � � � �  . j p g � o      ����  0 this_item_jpeg this_item_JPEG �  � � � r   � � � � � b   � � � � � b   � � � � � b   � � � � � b   � � � � � m   � � � � � � � 0 / o p t / l o c a l / b i n / c o n v e r t   " � o   � �����  0 this_item_unix this_item_Unix � m   � � � � � � �  "   " � o   � �����  0 this_item_jpeg this_item_JPEG � m   � � � � � � �  " � o      ���� 0 
convertcmd 
convertCmd �  ��� � I  � ��� ���
�� .sysoexecTEXT���     TEXT � o   � ����� 0 
convertcmd 
convertCmd��  ��  ��  ��  �� 0 	this_item    o   
 ���� 0 added_items    m     � ��                                                                                  MACS  alis    @  Macintosh HD               �[]BD ����
Finder.app                                                     �����[]        ����  
 cu             CoreServices  )/:System:Library:CoreServices:Finder.app/    
 F i n d e r . a p p    M a c i n t o s h   H D  &System/Library/CoreServices/Finder.app  / ��    R      ������
�� .ascrerr ****      � ****��  ��  ��  ��       �� � ���   � ��
�� .facofgetnull���     alis � �� ���� � ���
�� .facofgetnull���     alis�� 0 this_folder  �� ������
�� 
flst�� 0 added_items  ��   � 
���������������������� 0 this_folder  �� 0 added_items  �� 0 	this_item  ��  0 this_item_unix this_item_Unix�� 0 this_item_char  �� 0 char_itr  �� 0 last_period  �� 0 	this_char  ��  0 this_item_jpeg this_item_JPEG�� 0 
convertcmd 
convertCmd �  ��������� & .�� 6���� i� � � � ��~�}�|
�� 
kocl
�� 
cobj
�� .corecnte****       ****
�� 
kind
�� 
bool
�� 
psxp
�� 
cha 
� 
TEXT
�~ .sysoexecTEXT���     TEXT�}  �|  �� � �� � ��[��l kh ��,� 
 	��,� �&
 	��,� �& n��,E�O��-j E�O�E�OjE�O (h�j��/E�O��  
�E�OY hO�kE�[OY��O�[�\[Zk\Z�k2�&�%E�O�%�%�%a %E�O�j Y h[OY�qUW X  hascr  ��ޭ