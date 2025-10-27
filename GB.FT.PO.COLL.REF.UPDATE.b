SUBROUTINE GB.FT.PO.COLL.REF.UPDATE
*=================================================================================================================================
* Developed by       : Nuren Durdana Abha (FDS)
* Description        : Writes PO collection FT id on CHEQUE.REGISTER.SUPPLEMENT
* RTN Attached in    : APPLICATION: VERSION.CONTROL, ID: FUNDS.TRANSFER
* Routine Type       : INPUT routine
* Compilation Time   : 05 Nov, 2024 (16:00)
*=================================================================================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING CQ.ChqSubmit
    $USING EB.LocalReferences
    $USING FT.Contract
    
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
    
    Y.FT.ID= EB.SystemTables.getIdNew()
    Y.AC.NUM= EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitAcctNo)
    Y.PO.NUM= EB.SystemTables.getRNew(FT.Contract.FundsTransfer.StockNumber)
        
    Y.CRS.ID= 'PO.':Y.AC.NUM:'.':Y.PO.NUM
    
    EB.DataAccess.FRead(FN.CHQ.REG.SUP, Y.CRS.ID, CRS.REC, F.CHQ.REG.SUP, Y.ERR)
    Y.PO.STATUS= CRS.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsStatus>
    
    IF Y.PO.STATUS EQ 'CLEARED' THEN
        Y.TEMP= CRS.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsLocalRef>
        Y.TEMP<1,Y.COLL.TXN.REF.POS>= Y.FT.ID
        CRS.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsLocalRef>= Y.TEMP
    
        EB.DataAccess.FWrite(FN.CHQ.REG.SUP, Y.CRS.ID, CRS.REC)
    END
      
RETURN

END
