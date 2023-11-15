Procedure borrar_ocurrencia(Var l : Ocurrencias);

Var 
  p: Ocurrencias;
Begin
  While l <> Nil Do
    Begin
      p := l;
      l := l^.sig;
      dispose(p);
    End;
End;

Procedure agregarPalabraAlFinal(Var l: Ocurrencias; pa: Palabra);

Var p,q : Ocurrencias;
  palcant : PalabraCant;
Begin
  palcant.pal := pa;
  palcant.cant := 1;

  new(p);
  //crear nueva celda
  p^.palc := palcant;
  //cargar el elemento
  p^.sig := Nil;
  //es el último

  If l = Nil Then
    l := p
  Else
    Begin
      //busco el último de l
      q := l;
      While q^.sig <> Nil Do
        q := q^.sig;
      //engancho p a continuacion del último
      q^.sig := p;
    End;
End;


Function hash ( semilla, paso, N : Natural; p : Palabra ) : Natural;

Var 
  i: integer;
  codigo: Natural;
Begin
  codigo := semilla;
  For i := 1 To p.tope Do
    codigo := ((codigo * paso) + ord(p.cadena[i]));
  hash := codigo Mod N;
End;

Function comparaPalabra ( p1, p2 : Palabra ) : Comparacion;

Var 
  i: integer;
Begin
  i := 1;
  While (i <= p1.tope) And (i <= p2.tope) And (p1.cadena[i] = p2.cadena[i]) Do
    i := i + 1;
  If i > p1.tope Then
    If i > p2.tope Then
      comparaPalabra := igual
  Else
    comparaPalabra := menor
  Else If i > p2.tope Then
         comparaPalabra := mayor
  Else If p1.cadena[i] < p2.cadena[i] Then
         comparaPalabra := menor
  Else
    comparaPalabra := mayor;
End;

Function mayorPalabraCant( pc1, pc2 : PalabraCant ) : boolean;
Begin
  If pc1.cant > pc2.cant Then
    mayorPalabraCant := true
  Else If pc1.cant = pc2.cant Then
         If comparaPalabra(pc1.pal, pc2.pal) = mayor Then
           mayorPalabraCant := true
  Else
    mayorPalabraCant := false
  Else
    mayorPalabraCant := false;
End;

Procedure agregarOcurrencia (p : Palabra; Var pals : Ocurrencias);

Var 
  encontrado: boolean;
  actual: Ocurrencias;
Begin
  encontrado := false;
  actual := pals;
  While (actual <> Nil) And Not encontrado Do
    Begin
      If comparaPalabra(actual^.palc.pal, p) = igual Then
        Begin
          encontrado := true;
          actual^.palc.cant := actual^.palc.cant + 1;
        End
      Else
        Begin
          actual := actual^.sig;
        End;
    End;
  If Not encontrado Then
    agregarPalabraAlFinal(pals, p);
End;


Procedure inicializarPredictor ( Var pred: Predictor );

Var 
  i: integer;
Begin
  For i := 1 To MAXHASH Do
    borrar_ocurrencia(pred[i]);
End;

Procedure entrenarPredictor(txt: Texto; Var pred: Predictor);

Var 
  actual: Texto;
  p1, p2: Palabra;
Begin
  actual := txt;
  While actual^.sig <> Nil Do
    Begin
      p1 := actual^.info;
      p2 := actual^.sig^.info;
      agregarOcurrencia(p2, pred[hash(SEMILLA, PASO, MAXHASH, p1)]);
      actual := actual^.sig;
    End;
End;

Procedure insOrdAlternativas(pc: PalabraCant; Var alts: Alternativas);

Var 
  i, j, minIndex: integer;
  temp, min: PalabraCant;
Begin
  If alts.tope < MAXALTS Then
    Begin
      // Aún hay espacio, encontrar posición de inserción
      i := 1;
      While (i <= alts.tope) And
            mayorPalabraCant(alts.pals[i], pc) Do
        i := i + 1;

      // Desplazar elementos a partir de i para hacer espacio
      For j := alts.tope Downto i Do
        alts.pals[j + 1] := alts.pals[j];

      // Insertar el elemento
      alts.pals[i] := pc;
      alts.tope := alts.tope + 1;

    End
  Else If alts.tope = MAXALTS Then
         Begin
           i := 2;
           min := alts.pals[1];
           minIndex := 1;

           //Obtengo elemento mas chico
           While (i <= alts.tope) Do
             Begin
               If  mayorPalabraCant(min, alts.pals[i]) Then
                 Begin
                   min := alts.pals[i];
                   minIndex := i;
                 End;
               i := i + 1;
             End;

    //Si el elemento mas chico es menor que el que quiero insertar, lo reemplazo
           If mayorPalabraCant(pc, min) Then
             Begin
               alts.pals[minIndex] := pc;
             End;

           //Ordena la lista nuevamente
           For i := 1 To alts.tope - 1 Do
             For j := i + 1 To alts.tope Do
               If Not mayorPalabraCant(alts.pals[i], alts.pals[j]) Then
                 Begin
                   // Intercambia los elementos para ordenar de mayor a menor
                   temp := alts.pals[i];
                   alts.pals[i] := alts.pals[j];
                   alts.pals[j] := temp;
                 End;
         End;
End;



Procedure obtenerAlternativas(p: Palabra; pred: Predictor; Var alts:
                              Alternativas);

Var 
  actual: Ocurrencias;
Begin

  // Inicializar alts
  alts.tope := 0;

  // Obtener lista de ocurrencias para la palabra p
  actual := pred[hash(SEMILLA, PASO, MAXHASH, p)];

  // Recorrer la lista de ocurrencias
  While (actual <> Nil) And (alts.tope < MAXALTS) Do
    Begin

      // Insertar cada ocurrencia en alts usando insOrdAlternativas  
      insOrdAlternativas(actual^.palc, alts);

      // Pasar a la siguiente ocurrencia
      actual := actual^.sig;

    End;

End;
