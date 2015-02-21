//***************************************************************
	// This unit contains some structures required by WinRTOb. You
	//	don't need to get involved with this unit
	// It's reason to exist is mainly to reduce the complexity in
	// WinRTOb
unit AuxObjs;

interface

type
	pCONTROL_ITEM_ex	= ^tCONTROL_ITEM_ex;
	tCONTROL_ITEM_ex	= record
		WINRT_COMMAND,						// command to perform
		port,       						// port address
		value		: integer;     		// input or output data
		name		: string;				// variable name, if applicable
		dsize		: integer;				// size of variable waiting for data
		end;

	// tStack keeps the position of the active (not closed) _While or _If/_Else
	// there is one stack structure for all _While's and another for all _IF/_Else
	tStack	= record
		data		: array[1..8] of integer;			// up to 8 pending _While's or _If's allowed
		sp			: integer;
		end;

const
	NOVALUE		= pointer(-1);

implementation

end.

