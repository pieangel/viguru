unit StreamIO;

{== Unit StreamIO =====================================================}
{: Implements a text-file device driver that allows textfile-style I/O
   on streams.
@author Dr. Peter Below
@desc   Version 1.0 created 4 Januar 2001<BR>
        Current revision 1.0<BR>
        Last modified       4 Januar 2001<P>                           }
{======================================================================}

interface

uses
  Classes, SysUtils;

{-- AssignStream ------------------------------------------------------}
{: Attach a stream to a Textfile to allow I/O via WriteLn/ReadLn
@Param F is the textfile to attach the stream to
@Param S is the stream
@Precondition  S <> nil
@Desc The passed streams position will be set to 0 by Reset and Rewrite
  and to the streams end by Append. The stream is not freed when the
  textfile is closed via CloseFile and it has to stay in existence as
  long as the textfile is open.
}{ Created 4.1.2001 by P. Below

-----------------------------------------------------------------------}

procedure AssignStream(var F: Textfile; S: TStream);

Implementation

{-- GetDevStream ------------------------------------------------------}
{: Get the stream reference stored in the textrec userdata area
@Param F is the textfile record
@Returns the stream reference
@Postcondition result <> nil
}{ Created 4.1.2001 by P. Below

-----------------------------------------------------------------------}
function GetDevStream(var F: TTextRec ): TStream;
begin
  Move(F.Userdata, Result, Sizeof( Result ));
  Assert(Assigned( Result ));
end;

{-- DevIn -------------------------------------------------------------}
{: Called by Read, ReadLn etc. to fill the textfiles buffer from the
   stream.
@Param F is the textfile to operate on
@Returns 0 (no error)
}{ Created 4.1.2001 by P. Below

-----------------------------------------------------------------------}
function DevIn(var F: TTextRec ): Integer;
begin
  Result := 0;
  with F do
  begin
    BufEnd := GetDevStream(F).Read( BufPtr^, BufSize );
    BufPos := 0;
  end;
end; 

{-- DevFlushIn --------------------------------------------------------}
{: A dummy method, flush on input does nothing.
@Param F is the textfile to operate on
@Returns 0 (no error)
}{ Created 4.1.2001 by P. Below

-----------------------------------------------------------------------}
function DevFlushIn(var F: TTextRec ): Integer;
begin
  Result := 0;
end;

{-- DevOut ------------------------------------------------------------}
{: Write the textfile buffers content to the stream. Called by Write,
   WriteLn when the buffer becomes full. Also called by Flush.
@Param F is the textfile to operate on
@Returns 0 (no error)
@Raises EStreamError if the write failed for some reason.
}{ Created 4.1.2001 by P. Below

-----------------------------------------------------------------------}
function DevOut(var F: TTextRec ): Integer;
begin { DevOut }
  Result := 0;
  with F do
  if BufPos > 0 then
  begin
    GetDevStream(F).WriteBuffer( BufPtr^, BufPos );
    BufPos := 0;
  end;
end; 

{-- DevClose ----------------------------------------------------------}
{: Called by Closefile. Does nothing here.
@Param F is the textfile to operate on
@Returns 0 (no error)
}{ Created 4.1.2001 by P. Below

-----------------------------------------------------------------------}
Function DevClose( Var F: TTextRec ): Integer;
  Begin { DevClose }
    Result := 0;
  End; { DevClose }

{-- DevOpen -----------------------------------------------------------}
{: Called by Reset, Rewrite, or Append to prepare the textfile for I/O
@Param F is the textfile to operate on
@Returns 0 (no error)
}{ Created 4.1.2001 by P. Below

-----------------------------------------------------------------------}
function DevOpen( Var F: TTextRec ): Integer;
  Begin { DevOpen }
    Result := 0;
    With F Do Begin
      Case Mode Of
        fmInput: Begin { Reset }
            InOutFunc := @DevIn;
            FlushFunc := @DevFlushIn;
            BufPos := 0;
            BufEnd := 0;
            GetDevStream( F ).Position := 0;
          End; { Case fmInput }
        fmOutput: Begin { Rewrite }
            InOutFunc := @DevOut;
            FlushFunc := @DevOut;
            BufPos := 0;
            BufEnd := 0;
            GetDevStream( F ).Position := 0;
          End; { Case fmOutput }
        fmInOut: Begin { Append }
            Mode := fmOutput;
            DevOpen( F );
            GetDevStream(F).Seek( 0, soFromEnd );
          End; { Case fmInOut }
      End; { Case }
    End; { With }
  End; { DevOpen }

procedure AssignStream(var F: Textfile; S: TStream );
begin { AssignStream }
  Assert(Assigned(S));
  with TTextRec(F) do
  begin
    Mode := fmClosed;
    BufSize := SizeOf(Buffer);
    BufPtr := @Buffer;
    OpenFunc := @DevOpen;
    CloseFunc := @DevClose;
    Name[0] := #0;
    { Store stream reference into Userdata area }
    Move(S, Userdata, Sizeof(S));
  end;
end;

end.

