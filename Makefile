#Les variables automatiques :
#$@ valeur du  target
#$< nom du premier pré-requis associé au target
#$? nom des pré-requis plus récent que le target
#$^ liste sans répétition des pré-requis
#$+ comme $^ mais avec les répétitions
#$* nom du target avec le suffix tronqué

#Variables pour faciliter la saisie et les modifications dans le Makefile :
#Variable pour le compilateur
CC ?= gcc

#Variables pour la confection de la librairie :
#Options pour les lignes de code faites pour la confection des fichiers objets
CFLAGS += -fPIC -Wall
OBJETS = addition.o soustraction.o multiplication.o division.o
FICHIERSC = $(OBJETS:.o=.c)

#Noms des librairies statiques et dynamiques
LINKNAME := maBibArithmetique
libSTATIC := lib$(LINKNAME).a
MAJEUR = .1
MINEUR = .0
CORRECTION = .0
SONAMECOURT := lib$(LINKNAME).so
SONAME := $(SONAMECOURT)$(MAJEUR)
REALNAME := $(SONAME)$(MINEUR)$(CORRECTION)

#Options pour les librairies
libCFLAGS = -shared -fPIC -Wl,-soname,
libLDFLAGS = -L.
libLDLIBS = -lc

#Options pour l'archive
ARFLAGS = rcs

#Options des programmes en statique et dynamique
STATIC = arithmetique.static
DYNAMIC = arithmetique.shared
sharedLDFLAGS := -L.
sharedLDLIBS := -l$(LINKNAME)
staticLDFLAGS := -L.
staticLDLIBS := -l:$(libSTATIC)

#Conception du Makefile :
#Execution du programme en entier
all: $(DYNAMIC) $(STATIC)
	LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH ./$<

#Fabrication du fichier objet addition.o
$(OBJETS): CFLAGS := $(CFLAGS)

#Conception de l'archive pour la bibliothèque statique
$(libSTATIC)($(OBJETS)): ARFLAGS := $(ARFLAGS)
$(libSTATIC)($(OBJETS)): $(OBJETS)

#Règle pour appeler la conception de l'archive
$(libSTATIC): $(libSTATIC)($(OBJETS))

#Conception de la bibliothèque dynamique avec ses 2 liens symboliques
$(REALNAME): $(OBJETS)
	$(CC) $(libCFLAGS)$(SONAME) -o $@ $^
	ln -sf $@ $(SONAMECOURT)
	ln -sf $@ $(SONAME)

#Fabrication du fichier objet main.o
main.o: LDFLAGS := $(CFLAGS)

#Génération du programme static
$(STATIC): LDFLAGS := $(staticLDFLAGS)
$(STATIC): LDLIBS := $(staticLDLIBS)
$(STATIC): main.o $(libSTATIC)
	$(CC) -o $(STATIC) main.o $(staticLDFLAGS) $(staticLDLIBS)

#Génération du programme dynamique
$(DYNAMIC): LDFLAGS := $(sharedLDFLAGS)
$(DYNAMIC): LDLIBS := $(sharedLDLIBS)
$(DYNAMIC): main.o $(REALNAME)
	$(CC) -o $@ main.o $(sharedLDFLAGS) $(sharedLDLIBS)

#Execution du programme dynamique
execution: $(DYNAMIC)
	LD_LIBRARY_PATH=.:$LD_LIBRARY_PATH ./$^

clean:
	-rm *.o *rithmetique*