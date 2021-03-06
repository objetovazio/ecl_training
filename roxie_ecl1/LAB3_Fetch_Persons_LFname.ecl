IMPORT $, STD;

basefile := $.File_Persons_Slim.FilePlus;
basekey  := $.File_Persons_Slim.IDX_lname_fname;
cszfile  := $.File_LookupCSZ.FilePlus;

EXPORT Lab3_Fetch_Persons_LFname(STRING25 l_key, STRING15 f_key) := FUNCTION
    
    upper_f_key := STD.Str.ToUpperCase(f_key);
    upper_l_key := STD.Str.ToUpperCase(l_key);

    // Get all if empty
    base_filter := if(f_key = '', basekey(), basekey(FirstName = upper_f_key));
    filteredKey := if(l_key = '', base_filter(), base_filter(LastName = upper_l_key));

    // Filter if f_key is empty, since its optional
    // filteredKey := IF(f_key = '', 
    //                     basekey(LastName = l_key), 
    //                     basekey(LastName = l_key, FirstName = f_key));

    // Fetch persons based on filteredKey
    Fetch_Persons := FETCH(basefile, FilteredKey, RIGHT.RecPos);

    // Define output Record
    OutputRecord := RECORD
        RECORDOF(basefile) AND NOT [RecPos, CSZ_ID];
        RECORDOF(cszfile) AND NOT [RecPos, CSZ_ID];
    END;

    // Define TRANSFORM
    OutputRecord JoinPersonsCSZ(cszfile Le, basefile Ri) := TRANSFORM
        SELF := Le;
        SELF := Ri;
    END;

    // Return JOINED DATASET
    RETURN JOIN(cszfile, Fetch_Persons, LEFT.csz_id = RIGHT.csz_id, JoinPersonsCSZ(LEFT, RIGHT), ALL);
END;