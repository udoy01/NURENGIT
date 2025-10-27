SUBROUTINE GB.E.NOF.PO.COLL.LIST(Y.RETURN)
*=================================================================================================================================
* Developed by       : Nuren Durdana Abha (FDS)
* Description        : Shows data of Collected PO from CHEQUE.REGISTER.SUPPLEMENT application
* RTN Attached in    : APPLICATION: ENQUIRY, ID: GB.ENQ.PO.COLL.LIST
* Routine Type       : Enquiry
* Standard Selection : NOFILE.PO.COLL
* Compilation Time   : 09 Nov, 2024 (11:19)
*=================================================================================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING CQ.ChqSubmit
    $USING FT.Contract
    $USING TT.Contract
    $USING EB.Reports
    $USING EB.LocalReferences
            
    GOSUB INIT
    GOSUB OPENFILE
    GOSUB MAIN
RETURN
    
INIT:
    FN.CHQ.REG= 'F.CHEQUE.REGISTER.SUPPLEMENT'
    F.CHQ.REG= ''
    
    FN.CHQ.REG.HIS= 'F.CHEQUE.REGISTER.SUPPLEMENT$HIS'
    F.CHQ.REG.HIS= ''
    
    FN.FT= 'F.FUNDS.TRANSFER$NAU'
    F.FT= ''
    
    FN.TT= 'F.TELLER$NAU'
    F.TT= ''
    
    Y.CHQ.ID= ''
    Y.PO.NO= ''
    Y.PAY.TO= ''
    Y.ISS.AMT= ''
    Y.ISS.DT= ''
    Y.DATE.PRESENTED= ''
    Y.ORIGIN= ''
    Y.ORIGIN.REF= ''
    Y.COLL.TXN.REF= ''
RETURN
    
OPENFILE:
    EB.DataAccess.Opf(FN.CHQ.REG,F.CHQ.REG)
    EB.DataAccess.Opf(FN.CHQ.REG.HIS,F.CHQ.REG.HIS)
    EB.DataAccess.Opf(FN.FT,F.FT)
    EB.DataAccess.Opf(FN.TT,F.TT)
RETURN

MAIN:
    EB.LocalReferences.GetLocRef('CHEQUE.REGISTER.SUPPLEMENT','LT.COLL.TXN.REF', Y.COLL.TXN.REF.POS)
    
    SEL.CMD= 'SELECT ':FN.CHQ.REG:' STATUS EQ CLEARED AND ID.COMP1 EQ PO AND CO.CODE EQ ': EB.SystemTables.getIdCompany()
    EB.DataAccess.Readlist(SEL.CMD, SELECT.LIST, '', NO.OF.ITEM, RET.CODE)
    
    LOOP
        REMOVE TRN.ID FROM SELECT.LIST SETTING TXN.POS
    WHILE TRN.ID:TXN.POS
    
        Y.CHQ.ID= TRN.ID
        EB.DataAccess.FRead(FN.CHQ.REG,Y.CHQ.ID,CHQ.REC,F.CHQ.REG,Y.ERR)
        IF CHQ.REC THEN
            Y.COLL.TXN.REF= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsLocalRef,Y.COLL.TXN.REF.POS>
        END

        GOSUB CHECK.INAU.ENTRY
    REPEAT

    SEL.CMD.HIS= 'SELECT ':FN.CHQ.REG.HIS:' STATUS EQ CLEARED AND ID.COMP1 EQ PO AND CO.CODE EQ ': EB.SystemTables.getIdCompany()
    EB.DataAccess.Readlist(SEL.CMD.HIS, SELECT.LIST.HIS, '', NO.OF.ITEM.HIS, RET.CODE.HIS)
    LOOP
        REMOVE TRN.ID FROM SELECT.LIST.HIS SETTING TXN.POS
    WHILE TRN.ID:TXN.POS
    
        Y.HIS.CHQ.ID= TRN.ID

        GOSUB DATA.FETCH.HIS
    REPEAT

RETURN

CHECK.INAU.ENTRY:
    IF Y.COLL.TXN.REF[1,2] EQ 'FT' THEN
        EB.DataAccess.FRead(FN.FT,Y.COLL.TXN.REF,FT.REC,F.FT,FT.ERR)
        IF FT.REC EQ '' THEN
            GOSUB DATA.FETCH
        END
    END
    ELSE IF Y.COLL.TXN.REF[1,2] EQ 'TT' THEN
        EB.DataAccess.FRead(FN.TT,Y.COLL.TXN.REF,TT.REC,F.TT,TT.ERR)
        IF TT.REC EQ '' THEN
            GOSUB DATA.FETCH
        END
    END
RETURN

DATA.FETCH:
    EB.DataAccess.FRead(FN.CHQ.REG,Y.CHQ.ID,CHQ.REC,F.CHQ.REG,Y.ERR)
    IF CHQ.REC THEN
        Y.PO.NO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIdCompThr>
        Y.PAY.TO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsPayeeName>
        Y.ISS.AMT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsAmount>
        Y.ISS.DT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIssueDate>
        Y.DATE.PRESENTED= CHQ.REC<CQ.ChqSubmit.ChequeRegister.ChequeRegAuditDateTime>
        Y.ORIGIN.REF= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsOriginRef>
    END
    
    Y.RETURN<-1>= Y.ISS.DT:'*':Y.PO.NO:'*':Y.PAY.TO:'*':Y.ISS.AMT:'*':Y.ORIGIN.REF:'*':Y.DATE.PRESENTED[1,6]:'*':Y.COLL.TXN.REF
    !---------------*1*---------*2*-----------*3*----------*4*-----------*5*-----------------*6*-----------------------*7*
RETURN

DATA.FETCH.HIS:
    EB.DataAccess.FRead(FN.CHQ.REG.HIS,Y.HIS.CHQ.ID,CHQ.REC,F.CHQ.REG.HIS,Y.ERR)
    IF CHQ.REC THEN
        Y.PO.NO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIdCompThr>
        Y.PAY.TO= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsPayeeName>
        Y.ISS.AMT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsAmount>
        Y.ISS.DT= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsIssueDate>
        Y.DATE.PRESENTED= CHQ.REC<CQ.ChqSubmit.ChequeRegister.ChequeRegAuditDateTime>
        Y.ORIGIN.REF= CHQ.REC<CQ.ChqSubmit.ChequeRegisterSupplement.CcCrsOriginRef>
    END
    
    Y.RETURN<-1>= Y.ISS.DT:'*':Y.PO.NO:'*':Y.PAY.TO:'*':Y.ISS.AMT:'*':Y.ORIGIN.REF:'*':Y.DATE.PRESENTED[1,6]:'*':Y.COLL.TXN.REF
    !---------------*1*---------*2*-----------*3*----------*4*-----------*5*-----------------*6*-----------------------*7*
RETURN

END


