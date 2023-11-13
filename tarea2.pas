
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
  anterior, actual: Ocurrencias;
Begin
  encontrado := false;
  anterior := Nil;
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
          anterior := actual;
          actual := actual^.sig;
        End;
    End;
  If Not encontrado Then
    Begin
      new(actual);
      actual^.palc.pal := p;
      actual^.palc.cant := 1;
      If anterior = Nil Then

        pals := actual
      Else
        anterior^.sig := actual;
      actual^.sig := Nil;
    End;
End;


Procedure inicializarPredictor ( Var pred: Predictor );

Var 
  i: integer;
Begin
  For i := 1 To MAXHASH Do
    pred[i] := Nil;
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
  i, j: integer;
  menorEncontrado : boolean;
  temp: PalabraCant;
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





       // Si alts ya está lleno, busca el elemento más pequeño y reemplázalo
           menorEncontrado := False;
           i := 1;
           While (i <= alts.tope) And Not menorEncontrado Do
             Begin
               If mayorPalabraCant(pc, alts.pals[i]) Then
                 Begin
                   // Reemplaza el menor con pc
                   alts.pals[i] := pc;
                   menorEncontrado := True;
                 End;
               i := i + 1;
             End;

           // Ordena la lista nuevamente
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
