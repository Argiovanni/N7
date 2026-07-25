# TD Bus de Terrain 
* [sujet](https://moodle.inp-toulouse.fr/mod/resource/view.php?id=78510)

focus sur flux HK
Débit de chaque lien C = 50Mpbs (pour 1553 on serait plus sur de 1Mbps en pratique mais pour le TD on gard 50M pour 1553 et Spacewire)
## MIL-STD-1553

#### Q1)
flux de A~0~ vers PM
type d'échange : RT -> BC
PM send [cmd_word(Transmit)]
delay (donné par fournisseur) = 10microS
A~0~ send [status_word]
A~0~ send [data_words 1 -> n]

#### Q2)
20 octets pour ce type de flux et 2 octet par data_word -> 10 data_word (n=10)
12 words de 20 bit (240 bit) / C=50Mbps -> delay_tx + delay = 14,8*10E-6 s

#### Q3)
BC qui décide qui émet -> donc en théorie jamais 2 personne qui parle en même temps -> pas de contension sur les liens -> garantie du tps de trx
ici delay < période donc OK

#### Q4)
pas traité car mal pausé/mauvaise valeur dans le sujet mais l'idée c'est de voir que si le delay est plus grand que la période on ne respecte pas les contrainte

## Spacewire

### Délai de l'étude de cas

#### Q1)
**FLUX HK only**
* flux f10 (même chemin pour f11,f12 et f13)
l0/l1/l2/l3 -> l9 -> l15 -> l14
* pour f14 à f18
l4/l5/l6/l7/l8 -> l10 -> l15 -> l14
* f9 et f19
l34 -> l35 -> l11

Wctt(f~10~) = d(f10,l0)
= d(f10, l9) + d(f11, l9) + d(f12, l9) + d(f13, l9) // les 4 sont égaux en soit

d(f11, l9) = d(f11,l15) + max(d(f14,l15), d(f15,l15), d(f16,l15), d(f17,l15), d(f18,l15))

d(f14,l15) = d(f14,l14) = d(l14, NULL)

wctt(f10) = (T~10~ + T~11~ + T~12~ + T~13~ + 4*max(T~14~, T~15~, T~16~, T~17~, T~18~)) / C 

on considère T~i~ = un paquet de 20octets (rappel trame spacewire : [en-tête / data / EOP] pour se simplifié on ne compte pas la taille de l'en-tête et du EndOfPacket)

wctt(f10) = 20*8 * 8 / 50E6 = 25,6 microS

#### Q2)
wctt inférieur à période donc ok pour A0 (par contre A6 à une période trop faible donc contrainte pas respécter pour lui)

* *Nb :Délais dépend tjrs du lien avec la capacité/débit le plus lent*
### Qualité délai Pire cas avec méthode RC

#### Q1)
flux 2 bloque flux 1 qui va donc bloquer flux 0
(flemme de noter le dévellopement du calcul mais c'est comme pour l'exo d'avant)
wctt(f0) = (T0+T1+T2) / C

#### Q2)
(spacewire ne coupe pas la trx d'un msg)
mais au vu des tailles des msg, (ici 128 oct) f1 ne bloque pas f0 tout le long, car chaque entré dans un routeur à un buffer de 64oct. donc le vrai wctt(f0) est de (T0+T1) / C

#### Q3)

