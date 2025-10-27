SUBROUTINE GB.ENQ.BLD.AA.DEP.RDM.AC(ENQ.DATA)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History : Nuren Durdana Abha (FDS)
* Description          : added BRANCH.RESTRICTION part for restrict other branch modification
* Compilation Time     : 25 Feb, 2024 (17:31)
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INCLUDE I_ENQUIRY.COMMON
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING AC.AccountOpening
    $USING AA.Framework
    
    GOSUB INIT
    GOSUB PROCESS
RETURN
    
INIT:
    Y.AC.ID= ''
    Y.ARR.ID= ''
    Y.ARR.COM= ''
    Y.CUR.COM= ''
    
    FN.ARR= 'F.AA.ARRANGEMENT'
    F.ARR= ''
    EB.DataAccess.Opf(FN.ARR, F.ARR)
RETURN

PROCESS:
    LOCATE "ARRANGEMENT" IN ENQ.DATA<2,1> SETTING Y.DATA.POS THEN
        Y.AC.ID = ENQ.DATA<4,Y.DATA.POS>
    END
    
    IF Y.AC.ID[1,2] EQ 'AA' THEN
        Y.ARR.ID= Y.AC.ID
    
        GOSUB BRANCH.RESTRICTION
    END
    ELSE
        REC.ACC= AC.AccountOpening.Account.Read(Y.AC.ID, Error)
        Y.ARR.ID= REC.ACC<AC.AccountOpening.Account.ArrangementId>
    
        GOSUB BRANCH.RESTRICTION
    END
RETURN
    
BRANCH.RESTRICTION:
    EB.DataAccess.FRead(FN.ARR,Y.ARR.ID,ARR.REC,F.ARR,Y.ERR)
    Y.ARR.COM= ARR.REC<AA.Framework.Arrangement.ArrCoCode>
    Y.CUR.COM= EB.SystemTables.getIdCompany()
    
    IF Y.ARR.COM NE Y.CUR.COM THEN
        ENQ.DATA<4,Y.DATA.POS>= ''
    END
    ELSE
        ENQ.DATA<4,Y.DATA.POS>= Y.ARR.ID
    END
    
RETURN

END