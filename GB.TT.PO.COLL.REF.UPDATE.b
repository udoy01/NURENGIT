SUBROUTINE GB.TT.PO.COLL.REF.UPDATE
*=================================================================================================================================
* Developed by       : Nuren Durdana Abha (FDS)
* Description        : Writes PO collection TT id on CHEQUE.REGISTER.SUPPLEMENT
* RTN Attached in    : APPLICATION: VERSION.CONTROL, ID: TELLER
* Routine Type       : INPUT routine
* Compilation Time   : 04 Nov, 2024 (15:04)
*=================================================================================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING CQ.ChqSubmit
    $USING EB.LocalReferences
    $USING TT.Contract
    
    GOSUB INIT
    GOSUB OPENFILE
    GOSUB PROCESS
RETURN

INIT:
    FN.CHQ.REG.SUP= 'F.CHEQUE.REGISTER.SUPPLEMENT'
    F.CHQ.REG.SUP= ''
    
    EB.LocalReferences.GetLocRef('CHEQUE.REGISTER.SUPPLEMENT','LT.COLL.TXN.REF', Y.COLL.TXN.REF.POS)
RETURN

OPENFILE:
    EB.DataAccess.Opf(FN.CHQ.REG.SUP,F.CHQ.REG.SUP)
RETURN
    
PROCESS:
    Y.COLL.TXN.REF= EB.SystemTables.getRNew(CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsLocalRef)<1,Y.COLL.TXN.REF.POS>
    
    Y.TT.ID= EB.SystemTables.getIdNew()
    Y.AC.NUM= EB.SystemTables.getRNew(TT.Contract.Teller.TeAccountOne)
    Y.DD.NUM= EB.SystemTables.getRNew(TT.Contract.Teller.TeStockNumber)
        
    Y.CRS.ID= 'PO.':Y.AC.NUM:'.':Y.DD.NUM
    
    EB.DataAccess.FRead(FN.CHQ.REG.SUP, Y.CRS.ID, CRS.REC, F.CHQ.REG.SUP, Y.ERR)
    Y.PO.STATUS= CRS.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsStatus>
    
    IF Y.PO.STATUS EQ 'CLEARED' THEN
        Y.TEMP = CRS.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsLocalRef>
        Y.TEMP<1,Y.COLL.TXN.REF.POS>= Y.TT.ID
        CRS.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsLocalRef> = Y.TEMP
    
        EB.DataAccess.FWrite(FN.CHQ.REG.SUP, Y.CRS.ID, CRS.REC)
    END

RETURN
END

