from typing import Optional
import datetime

from sqlalchemy import Column, DateTime, Index, PrimaryKeyConstraint, Table, VARCHAR
from sqlalchemy.dialects.oracle import LONG, NUMBER, RAW, ROWID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column
from sqlalchemy.sql.sqltypes import NullType

class Base(DeclarativeBase):
    pass


class LogmnrAttrcol(Base):
    __tablename__ = 'logmnr_attrcol$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_attrcol$_pk'),
        Index('logmnr_i1attrcol$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    INTCOL_: Mapped[Optional[float]] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    name: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrAttribute(Base):
    __tablename__ = 'logmnr_attribute$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'toid', 'VERSION#', 'ATTRIBUTE#', name='logmnr_attribute$_pk'),
        Index('logmnr_i1attribute$', 'logmnr_uid', 'toid', 'VERSION#', 'ATTRIBUTE#'),
        {'schema': 'SYSTEM'}
    )

    toid: Mapped[bytes] = mapped_column(RAW, primary_key=True)
    VERSION_: Mapped[Optional[float]] = mapped_column('VERSION#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    ATTRIBUTE_: Mapped[Optional[float]] = mapped_column('ATTRIBUTE#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    attr_toid: Mapped[Optional[bytes]] = mapped_column(RAW)
    ATTR_VERSION_: Mapped[Optional[float]] = mapped_column('ATTR_VERSION#', NUMBER(asdecimal=False))
    SYNOBJ_: Mapped[Optional[float]] = mapped_column('SYNOBJ#', NUMBER(asdecimal=False))
    properties: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    charsetid: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    charsetform: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    length: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    PRECISION_: Mapped[Optional[float]] = mapped_column('PRECISION#', NUMBER(asdecimal=False))
    scale: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    externname: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    xflags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare4: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare5: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    setter: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    getter: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrCcol(Base):
    __tablename__ = 'logmnr_ccol$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'CON#', 'INTCOL#', name='logmnr_ccol$_pk'),
        Index('logmnr_i1ccol$', 'logmnr_uid', 'CON#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    INTCOL_: Mapped[float] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True)
    CON_: Mapped[Optional[float]] = mapped_column('CON#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(asdecimal=False))
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(asdecimal=False))
    POS_: Mapped[Optional[float]] = mapped_column('POS#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrCdef(Base):
    __tablename__ = 'logmnr_cdef$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'CON#', name='logmnr_cdef$_pk'),
        Index('logmnr_i1cdef$', 'logmnr_uid', 'CON#'),
        Index('logmnr_i2cdef$', 'logmnr_uid', 'ROBJ#'),
        Index('logmnr_i3cdef$', 'logmnr_uid', 'OBJ#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), nullable=False)
    CON_: Mapped[Optional[float]] = mapped_column('CON#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    cols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    TYPE_: Mapped[Optional[float]] = mapped_column('TYPE#', NUMBER(asdecimal=False))
    ROBJ_: Mapped[Optional[float]] = mapped_column('ROBJ#', NUMBER(asdecimal=False))
    RCON_: Mapped[Optional[float]] = mapped_column('RCON#', NUMBER(asdecimal=False))
    enabled: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defer: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrCol(Base):
    __tablename__ = 'logmnr_col$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_col$_pk'),
        Index('logmnr_i1col$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        Index('logmnr_i2col$', 'logmnr_uid', 'OBJ#', 'name'),
        Index('logmnr_i3col$', 'logmnr_uid', 'OBJ#', 'COL#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(22, 0, False), primary_key=True)
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(22, 0, False))
    SEGCOL_: Mapped[Optional[float]] = mapped_column('SEGCOL#', NUMBER(22, 0, False))
    name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    TYPE_: Mapped[Optional[float]] = mapped_column('TYPE#', NUMBER(22, 0, False))
    length: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    PRECISION_: Mapped[Optional[float]] = mapped_column('PRECISION#', NUMBER(22, 0, False))
    scale: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    null_: Mapped[Optional[float]] = mapped_column('null$', NUMBER(22, 0, False))
    INTCOL_: Mapped[Optional[float]] = mapped_column('INTCOL#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    property: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    charsetid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    charsetform: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    collid: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    COLLINTCOL_: Mapped[Optional[float]] = mapped_column('COLLINTCOL#', NUMBER(asdecimal=False))
    ACDRRESCOL_: Mapped[Optional[float]] = mapped_column('ACDRRESCOL#', NUMBER(asdecimal=False))


class LogmnrColtype(Base):
    __tablename__ = 'logmnr_coltype$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_coltype$_pk'),
        Index('logmnr_i1coltype$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(asdecimal=False))
    INTCOL_: Mapped[Optional[float]] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    toid: Mapped[Optional[bytes]] = mapped_column(RAW)
    VERSION_: Mapped[Optional[float]] = mapped_column('VERSION#', NUMBER(asdecimal=False))
    packed: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    intcols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    INTCOL_S: Mapped[Optional[bytes]] = mapped_column('INTCOL#S', RAW)
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    TYPIDCOL_: Mapped[Optional[float]] = mapped_column('TYPIDCOL#', NUMBER(asdecimal=False))
    SYNOBJ_: Mapped[Optional[float]] = mapped_column('SYNOBJ#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrCon(Base):
    __tablename__ = 'logmnr_con$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'CON#', name='logmnr_con$_pk'),
        Index('logmnr_i1con$', 'logmnr_uid', 'CON#'),
        {'schema': 'SYSTEM'}
    )

    OWNER_: Mapped[float] = mapped_column('OWNER#', NUMBER(asdecimal=False), nullable=False)
    name: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    CON_: Mapped[float] = mapped_column('CON#', NUMBER(asdecimal=False), primary_key=True)
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    start_scnbas: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    start_scnwrp: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))


class LogmnrContainer(Base):
    __tablename__ = 'logmnr_container$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', name='logmnr_container$_pk'),
        Index('logmnr_i1container$', 'logmnr_uid', 'CON_ID#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    CON_ID_: Mapped[float] = mapped_column('CON_ID#', NUMBER(asdecimal=False), nullable=False)
    dbid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    con_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    create_scnwrp: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    create_scnbas: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    status: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    vsn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    FED_ROOT_CON_ID_: Mapped[Optional[float]] = mapped_column('FED_ROOT_CON_ID#', NUMBER(asdecimal=False))


class LogmnrDictionary(Base):
    __tablename__ = 'logmnr_dictionary$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', name='logmnr_dictionary$_pk'),
        Index('logmnr_i1dictionary$', 'logmnr_uid'),
        {'schema': 'SYSTEM'}
    )

    db_dict_objectcount: Mapped[float] = mapped_column(NUMBER(22, 0, False), nullable=False)
    db_name: Mapped[Optional[str]] = mapped_column(VARCHAR(27))
    db_id: Mapped[Optional[float]] = mapped_column(NUMBER(20, 0, False))
    db_created: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    db_dict_created: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    db_dict_scn: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    db_thread_map: Mapped[Optional[bytes]] = mapped_column(RAW)
    db_txn_scnbas: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    db_txn_scnwrp: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    DB_RESETLOGS_CHANGE_: Mapped[Optional[float]] = mapped_column('DB_RESETLOGS_CHANGE#', NUMBER(22, 0, False))
    db_resetlogs_time: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    db_version_time: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    db_redo_type_id: Mapped[Optional[str]] = mapped_column(VARCHAR(8))
    db_redo_release: Mapped[Optional[str]] = mapped_column(VARCHAR(60))
    db_character_set: Mapped[Optional[str]] = mapped_column(VARCHAR(192))
    db_version: Mapped[Optional[str]] = mapped_column(VARCHAR(240))
    db_status: Mapped[Optional[str]] = mapped_column(VARCHAR(240))
    db_global_name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    db_dict_maxobjects: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    pdb_name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    pdb_id: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    pdb_uid: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    pdb_dbid: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    pdb_guid: Mapped[Optional[bytes]] = mapped_column(RAW)
    pdb_create_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    pdb_count: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    pdb_global_name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    FED_ROOT_CON_ID_: Mapped[Optional[float]] = mapped_column('FED_ROOT_CON_ID#', NUMBER(asdecimal=False))


class LogmnrDictstate(Base):
    __tablename__ = 'logmnr_dictstate$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', name='logmnr_dictstate$_pk'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True)
    start_scnbas: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    start_scnwrp: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    end_scnbas: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    end_scnwrp: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    redo_thread: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    rbasqn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    rbablk: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    rbabyte: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrEnc(Base):
    __tablename__ = 'logmnr_enc$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'OWNER#', name='logmnr_enc$_pk'),
        Index('logmnr_i1enc$', 'logmnr_uid', 'OBJ#', 'OWNER#'),
        {'schema': 'SYSTEM'}
    )

    mkeyid: Mapped[str] = mapped_column(VARCHAR(192), nullable=False)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    OWNER_: Mapped[Optional[float]] = mapped_column('OWNER#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    encalg: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    intalg: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    colklc: Mapped[Optional[bytes]] = mapped_column(RAW)
    klclen: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    flag: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrIcol(Base):
    __tablename__ = 'logmnr_icol$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_icol$_pk'),
        Index('logmnr_i1icol$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    INTCOL_: Mapped[float] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    BO_: Mapped[Optional[float]] = mapped_column('BO#', NUMBER(asdecimal=False))
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(asdecimal=False))
    POS_: Mapped[Optional[float]] = mapped_column('POS#', NUMBER(asdecimal=False))
    SEGCOL_: Mapped[Optional[float]] = mapped_column('SEGCOL#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrIdnseq(Base):
    __tablename__ = 'logmnr_idnseq$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_idnseq$_pk'),
        Index('logmnr_i1idnseq$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        Index('logmnr_i2idnseq$', 'logmnr_uid', 'SEQOBJ#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    INTCOL_: Mapped[float] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True)
    SEQOBJ_: Mapped[float] = mapped_column('SEQOBJ#', NUMBER(asdecimal=False), nullable=False)
    startwith: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrInd(Base):
    __tablename__ = 'logmnr_ind$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', name='logmnr_ind$_pk'),
        Index('logmnr_i1ind$', 'logmnr_uid', 'OBJ#'),
        Index('logmnr_i2ind$', 'logmnr_uid', 'BO#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(22, 0, False), primary_key=True)
    BO_: Mapped[Optional[float]] = mapped_column('BO#', NUMBER(22, 0, False))
    cols: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    TYPE_: Mapped[Optional[float]] = mapped_column('TYPE#', NUMBER(22, 0, False))
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    property: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrIndcompart(Base):
    __tablename__ = 'logmnr_indcompart$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', name='logmnr_indcompart$_pk'),
        Index('logmnr_i1indcompart$', 'logmnr_uid', 'OBJ#'),
        {'schema': 'SYSTEM'}
    )

    PART_: Mapped[float] = mapped_column('PART#', NUMBER(asdecimal=False), nullable=False)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    DATAOBJ_: Mapped[Optional[float]] = mapped_column('DATAOBJ#', NUMBER(asdecimal=False))
    BO_: Mapped[Optional[float]] = mapped_column('BO#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrIndpart(Base):
    __tablename__ = 'logmnr_indpart$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'BO#', name='logmnr_indpart$_pk'),
        Index('logmnr_i1indpart$', 'logmnr_uid', 'OBJ#', 'BO#'),
        Index('logmnr_i2indpart$', 'logmnr_uid', 'BO#'),
        {'schema': 'SYSTEM'}
    )

    TS_: Mapped[float] = mapped_column('TS#', NUMBER(asdecimal=False), nullable=False)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    BO_: Mapped[Optional[float]] = mapped_column('BO#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    PART_: Mapped[Optional[float]] = mapped_column('PART#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrIndsubpart(Base):
    __tablename__ = 'logmnr_indsubpart$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'POBJ#', name='logmnr_indsubpart$_pk'),
        Index('logmnr_i1indsubpart$', 'logmnr_uid', 'OBJ#', 'POBJ#'),
        {'schema': 'SYSTEM'}
    )

    TS_: Mapped[float] = mapped_column('TS#', NUMBER(22, 0, False), nullable=False)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    DATAOBJ_: Mapped[Optional[float]] = mapped_column('DATAOBJ#', NUMBER(22, 0, False))
    POBJ_: Mapped[Optional[float]] = mapped_column('POBJ#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    SUBPART_: Mapped[Optional[float]] = mapped_column('SUBPART#', NUMBER(22, 0, False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrKopm(Base):
    __tablename__ = 'logmnr_kopm$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'name', name='logmnr_kopm$_pk'),
        Index('logmnr_i1kopm$', 'logmnr_uid', 'name'),
        {'schema': 'SYSTEM'}
    )

    name: Mapped[str] = mapped_column(VARCHAR(384), primary_key=True)
    length: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    metadata_: Mapped[Optional[bytes]] = mapped_column('metadata', RAW)
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrLob(Base):
    __tablename__ = 'logmnr_lob$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_lob$_pk'),
        Index('logmnr_i1lob$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    chunk: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    INTCOL_: Mapped[Optional[float]] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(asdecimal=False))
    LOBJ_: Mapped[Optional[float]] = mapped_column('LOBJ#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrLobfrag(Base):
    __tablename__ = 'logmnr_lobfrag$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'FRAGOBJ#', name='logmnr_lobfrag$_pk'),
        Index('logmnr_i1lobfrag$', 'logmnr_uid', 'FRAGOBJ#'),
        {'schema': 'SYSTEM'}
    )

    FRAG_: Mapped[float] = mapped_column('FRAG#', NUMBER(asdecimal=False), nullable=False)
    FRAGOBJ_: Mapped[Optional[float]] = mapped_column('FRAGOBJ#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    PARENTOBJ_: Mapped[Optional[float]] = mapped_column('PARENTOBJ#', NUMBER(asdecimal=False))
    TABFRAGOBJ_: Mapped[Optional[float]] = mapped_column('TABFRAGOBJ#', NUMBER(asdecimal=False))
    INDFRAGOBJ_: Mapped[Optional[float]] = mapped_column('INDFRAGOBJ#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrLogmnrBuildlog(Base):
    __tablename__ = 'logmnr_logmnr_buildlog'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'initial_xid', name='logmnr_logmnr_buildlog_pk'),
        Index('logmnr_i1logmnr_buildlog', 'logmnr_uid', 'initial_xid'),
        {'schema': 'SYSTEM'}
    )

    initial_xid: Mapped[str] = mapped_column(VARCHAR(22), primary_key=True)
    build_date: Mapped[Optional[str]] = mapped_column(VARCHAR(20))
    db_txn_scnbas: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    db_txn_scnwrp: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    current_build_state: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    completion_status: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    marked_log_file_low_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    cdb_xid: Mapped[Optional[str]] = mapped_column(VARCHAR(22))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrNtab(Base):
    __tablename__ = 'logmnr_ntab$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_ntab$_pk'),
        Index('logmnr_i1ntab$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        Index('logmnr_i2ntab$', 'logmnr_uid', 'NTAB#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(asdecimal=False))
    INTCOL_: Mapped[Optional[float]] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    NTAB_: Mapped[Optional[float]] = mapped_column('NTAB#', NUMBER(asdecimal=False))
    name: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrObj(Base):
    __tablename__ = 'logmnr_obj$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', name='logmnr_obj$_pk'),
        Index('logmnr_i1obj$', 'logmnr_uid', 'OBJ#'),
        Index('logmnr_i2obj$', 'logmnr_uid', 'oid$'),
        Index('logmnr_i3obj$', 'logmnr_uid', 'name'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(22, 0, False), primary_key=True)
    OBJV_: Mapped[Optional[float]] = mapped_column('OBJV#', NUMBER(22, 0, False))
    OWNER_: Mapped[Optional[float]] = mapped_column('OWNER#', NUMBER(22, 0, False))
    name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    namespace: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    subname: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    TYPE_: Mapped[Optional[float]] = mapped_column('TYPE#', NUMBER(22, 0, False))
    oid_: Mapped[Optional[bytes]] = mapped_column('oid$', RAW)
    remoteowner: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    linkname: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    spare3: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    stime: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    start_scnbas: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    start_scnwrp: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))


class LogmnrOpqtype(Base):
    __tablename__ = 'logmnr_opqtype$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_opqtype$_pk'),
        Index('logmnr_i1opqtype$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    INTCOL_: Mapped[float] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True)
    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    type: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    lobcol: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    objcol: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    extracol: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    schemaoid: Mapped[Optional[bytes]] = mapped_column(RAW)
    elemnum: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    schemaurl: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrPartobj(Base):
    __tablename__ = 'logmnr_partobj$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', name='logmnr_partobj$_pk'),
        Index('logmnr_i1partobj$', 'logmnr_uid', 'OBJ#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    parttype: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    partcnt: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    partkeycols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    DEFTS_: Mapped[Optional[float]] = mapped_column('DEFTS#', NUMBER(asdecimal=False))
    defpctfree: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defpctused: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defpctthres: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    definitrans: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defmaxtrans: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    deftiniexts: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defextsize: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defminexts: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defmaxexts: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defextpct: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    deflists: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    defgroups: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    deflogging: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    definclcol: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    parameters: Mapped[Optional[str]] = mapped_column(VARCHAR(3000))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrProps(Base):
    __tablename__ = 'logmnr_props$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'name', name='logmnr_props$_pk'),
        Index('logmnr_i1props$', 'logmnr_uid', 'name'),
        {'schema': 'SYSTEM'}
    )

    name: Mapped[str] = mapped_column(VARCHAR(384), primary_key=True)
    value_: Mapped[Optional[str]] = mapped_column('value$', VARCHAR(4000))
    comment_: Mapped[Optional[str]] = mapped_column('comment$', VARCHAR(4000))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrRefcon(Base):
    __tablename__ = 'logmnr_refcon$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_refcon$_pk'),
        Index('logmnr_i1refcon$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(asdecimal=False))
    INTCOL_: Mapped[Optional[float]] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    reftyp: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    stabid: Mapped[Optional[bytes]] = mapped_column(RAW)
    expctoid: Mapped[Optional[bytes]] = mapped_column(RAW)
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrSeed(Base):
    __tablename__ = 'logmnr_seed$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', name='logmnr_seed$_pk'),
        Index('logmnr_i1seed$', 'logmnr_uid', 'OBJ#', 'INTCOL#'),
        Index('logmnr_i2seed$', 'logmnr_uid', 'schemaname', 'table_name', 'col_name', 'OBJ#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    null_: Mapped[float] = mapped_column('null$', NUMBER(asdecimal=False), nullable=False)
    seed_version: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    gather_version: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    schemaname: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    OBJV_: Mapped[Optional[float]] = mapped_column('OBJV#', NUMBER(22, 0, False))
    table_name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    col_name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(asdecimal=False))
    INTCOL_: Mapped[Optional[float]] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    SEGCOL_: Mapped[Optional[float]] = mapped_column('SEGCOL#', NUMBER(asdecimal=False))
    TYPE_: Mapped[Optional[float]] = mapped_column('TYPE#', NUMBER(asdecimal=False))
    length: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    PRECISION_: Mapped[Optional[float]] = mapped_column('PRECISION#', NUMBER(asdecimal=False))
    scale: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrShardTs(Base):
    __tablename__ = 'logmnr_shard_ts'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'tablespace_name', name='logmnr_shard_ts_pk'),
        Index('logmnr_i1shard_ts', 'logmnr_uid', 'tablespace_name'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    tablespace_name: Mapped[str] = mapped_column(VARCHAR(90), primary_key=True)
    chunk_number: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    start_scnbas: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    start_scnwrp: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))


class LogmnrSubcoltype(Base):
    __tablename__ = 'logmnr_subcoltype$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'INTCOL#', 'toid', name='logmnr_subcoltype$_pk'),
        Index('logmnr_i1subcoltype$', 'logmnr_uid', 'OBJ#', 'INTCOL#', 'toid'),
        {'schema': 'SYSTEM'}
    )

    INTCOL_: Mapped[float] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True)
    toid: Mapped[bytes] = mapped_column(RAW, primary_key=True)
    VERSION_: Mapped[float] = mapped_column('VERSION#', NUMBER(asdecimal=False), nullable=False)
    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    intcols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    INTCOL_S: Mapped[Optional[bytes]] = mapped_column('INTCOL#S', RAW)
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    SYNOBJ_: Mapped[Optional[float]] = mapped_column('SYNOBJ#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrTab(Base):
    __tablename__ = 'logmnr_tab$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', name='logmnr_tab$_pk'),
        Index('logmnr_i1tab$', 'logmnr_uid', 'OBJ#'),
        Index('logmnr_i2tab$', 'logmnr_uid', 'BOBJ#'),
        {'schema': 'SYSTEM'}
    )

    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(22, 0, False), primary_key=True)
    TS_: Mapped[Optional[float]] = mapped_column('TS#', NUMBER(22, 0, False))
    cols: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    property: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    intcols: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    kernelcols: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    BOBJ_: Mapped[Optional[float]] = mapped_column('BOBJ#', NUMBER(22, 0, False))
    trigflag: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    acdrflags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    ACDRTSOBJ_: Mapped[Optional[float]] = mapped_column('ACDRTSOBJ#', NUMBER(asdecimal=False))
    ACDRROWTSINTCOL_: Mapped[Optional[float]] = mapped_column('ACDRROWTSINTCOL#', NUMBER(asdecimal=False))


class LogmnrTabcompart(Base):
    __tablename__ = 'logmnr_tabcompart$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', name='logmnr_tabcompart$_pk'),
        Index('logmnr_i1tabcompart$', 'logmnr_uid', 'OBJ#'),
        Index('logmnr_i2tabcompart$', 'logmnr_uid', 'BO#'),
        {'schema': 'SYSTEM'}
    )

    PART_: Mapped[float] = mapped_column('PART#', NUMBER(22, 0, False), nullable=False)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    BO_: Mapped[Optional[float]] = mapped_column('BO#', NUMBER(22, 0, False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrTabpart(Base):
    __tablename__ = 'logmnr_tabpart$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'BO#', name='logmnr_tabpart$_pk'),
        Index('logmnr_i1tabpart$', 'logmnr_uid', 'OBJ#', 'BO#'),
        Index('logmnr_i2tabpart$', 'logmnr_uid', 'BO#'),
        {'schema': 'SYSTEM'}
    )

    BO_: Mapped[float] = mapped_column('BO#', NUMBER(22, 0, False), primary_key=True)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    TS_: Mapped[Optional[float]] = mapped_column('TS#', NUMBER(22, 0, False))
    PART_: Mapped[Optional[float]] = mapped_column('PART#', NUMBER(asdecimal=False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrTabsubpart(Base):
    __tablename__ = 'logmnr_tabsubpart$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'POBJ#', name='logmnr_tabsubpart$_pk'),
        Index('logmnr_i1tabsubpart$', 'logmnr_uid', 'OBJ#', 'POBJ#'),
        Index('logmnr_i2tabsubpart$', 'logmnr_uid', 'POBJ#'),
        {'schema': 'SYSTEM'}
    )

    TS_: Mapped[float] = mapped_column('TS#', NUMBER(22, 0, False), nullable=False)
    OBJ_: Mapped[Optional[float]] = mapped_column('OBJ#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    DATAOBJ_: Mapped[Optional[float]] = mapped_column('DATAOBJ#', NUMBER(22, 0, False))
    POBJ_: Mapped[Optional[float]] = mapped_column('POBJ#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    SUBPART_: Mapped[Optional[float]] = mapped_column('SUBPART#', NUMBER(22, 0, False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrTs(Base):
    __tablename__ = 'logmnr_ts$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'TS#', name='logmnr_ts$_pk'),
        Index('logmnr_i1ts$', 'logmnr_uid', 'TS#'),
        {'schema': 'SYSTEM'}
    )

    blocksize: Mapped[float] = mapped_column(NUMBER(22, 0, False), nullable=False)
    TS_: Mapped[Optional[float]] = mapped_column('TS#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    name: Mapped[Optional[str]] = mapped_column(VARCHAR(90))
    OWNER_: Mapped[Optional[float]] = mapped_column('OWNER#', NUMBER(22, 0, False))
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    start_scnbas: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    start_scnwrp: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))


class LogmnrType(Base):
    __tablename__ = 'logmnr_type$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'toid', 'VERSION#', name='logmnr_type$_pk'),
        Index('logmnr_i1type$', 'logmnr_uid', 'toid', 'VERSION#'),
        {'schema': 'SYSTEM'}
    )

    toid: Mapped[bytes] = mapped_column(RAW, primary_key=True)
    VERSION_: Mapped[Optional[float]] = mapped_column('VERSION#', NUMBER(asdecimal=False), primary_key=True, nullable=True)
    version: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    tvoid: Mapped[Optional[bytes]] = mapped_column(RAW)
    typecode: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    properties: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    attributes: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    methods: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    hiddenmethods: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    supertypes: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    subtypes: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    externtype: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    externname: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    helperclassname: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    local_attrs: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    local_methods: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    typeid: Mapped[Optional[bytes]] = mapped_column(RAW)
    roottoid: Mapped[Optional[bytes]] = mapped_column(RAW)
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    supertoid: Mapped[Optional[bytes]] = mapped_column(RAW)
    hashcode: Mapped[Optional[bytes]] = mapped_column(RAW)
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))


class LogmnrUser(Base):
    __tablename__ = 'logmnr_user$'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'USER#', name='logmnr_user$_pk'),
        Index('logmnr_i1user$', 'logmnr_uid', 'USER#'),
        Index('logmnr_i2user$', 'logmnr_uid', 'name'),
        {'schema': 'SYSTEM'}
    )

    name: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    USER_: Mapped[Optional[float]] = mapped_column('USER#', NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_uid: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False), primary_key=True, nullable=True)
    logmnr_flags: Mapped[Optional[float]] = mapped_column(NUMBER(22, 0, False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))


class LogmnrcConGg(Base):
    __tablename__ = 'logmnrc_con_gg'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'CON#', 'commit_scn', name='logmnrc_con_gg_pk'),
        Index('logmnrc_i1congg', 'logmnr_uid', 'BASEOBJ#', 'BASEOBJV#', 'commit_scn'),
        Index('logmnrc_i2congg', 'logmnr_uid', 'drop_scn'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    CON_: Mapped[float] = mapped_column('CON#', NUMBER(asdecimal=False), primary_key=True)
    name: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    commit_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    BASEOBJ_: Mapped[float] = mapped_column('BASEOBJ#', NUMBER(asdecimal=False), nullable=False)
    BASEOBJV_: Mapped[float] = mapped_column('BASEOBJV#', NUMBER(asdecimal=False), nullable=False)
    flags: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    INDEXOBJ_: Mapped[Optional[float]] = mapped_column('INDEXOBJ#', NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare4: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    spare5: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    spare6: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrcConcolGg(Base):
    __tablename__ = 'logmnrc_concol_gg'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'CON#', 'commit_scn', 'INTCOL#', name='logmnrc_concol_gg_pk'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    CON_: Mapped[float] = mapped_column('CON#', NUMBER(asdecimal=False), primary_key=True)
    commit_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    INTCOL_: Mapped[float] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True)
    POS_: Mapped[Optional[float]] = mapped_column('POS#', NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrcGsba(Base):
    __tablename__ = 'logmnrc_gsba'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'as_of_scn', name='logmnrc_gsba_pk'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    as_of_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    fdo_length: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    fdo_value: Mapped[Optional[bytes]] = mapped_column(RAW)
    charsetid: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    ncharsetid: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    dbtimezone_len: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    dbtimezone_value: Mapped[Optional[str]] = mapped_column(VARCHAR(192))
    logmnr_spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(1000))
    logmnr_spare4: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    db_global_name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))


class LogmnrcGsii(Base):
    __tablename__ = 'logmnrc_gsii'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', name='logmnrc_gsii_pk'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    BO_: Mapped[float] = mapped_column('BO#', NUMBER(asdecimal=False), nullable=False)
    INDTYPE_: Mapped[float] = mapped_column('INDTYPE#', NUMBER(asdecimal=False), nullable=False)
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(1000))
    logmnr_spare4: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)


class LogmnrcGtcs(Base):
    __tablename__ = 'logmnrc_gtcs'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'OBJV#', 'INTCOL#', name='logmnrc_gtcs_pk'),
        Index('logmnrc_i2gtcs', 'logmnr_uid', 'OBJ#', 'OBJV#', 'SEGCOL#', 'INTCOL#'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    OBJV_: Mapped[float] = mapped_column('OBJV#', NUMBER(asdecimal=False), primary_key=True)
    SEGCOL_: Mapped[float] = mapped_column('SEGCOL#', NUMBER(asdecimal=False), nullable=False)
    INTCOL_: Mapped[float] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True)
    colname: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    TYPE_: Mapped[float] = mapped_column('TYPE#', NUMBER(asdecimal=False), nullable=False)
    length: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    precision: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    scale: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    interval_leading_precision: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    interval_trailing_precision: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    property: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    toid: Mapped[Optional[bytes]] = mapped_column(RAW)
    charsetid: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    charsetform: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    typename: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    fqcolname: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    numintcols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    numattrs: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    adtorder: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(1000))
    logmnr_spare4: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    logmnr_spare5: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare6: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare7: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare8: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare9: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    COL_: Mapped[Optional[float]] = mapped_column('COL#', NUMBER(asdecimal=False))
    xtypeschemaname: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    xtypename: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    xfqcolname: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    xtopintcol: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xreffedtableobjn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xreffedtableobjv: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xcoltypeflags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xopqtypetype: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xopqtypeflags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xopqlobintcol: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xopqobjintcol: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xxmlintcol: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    EAOWNER_: Mapped[Optional[float]] = mapped_column('EAOWNER#', NUMBER(asdecimal=False))
    eamkeyid: Mapped[Optional[str]] = mapped_column(VARCHAR(192))
    eaencalg: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    eaintalg: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    eacolklc: Mapped[Optional[bytes]] = mapped_column(RAW)
    eaklclen: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    eaflags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnrderivedflags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    collid: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    COLLINTCOL_: Mapped[Optional[float]] = mapped_column('COLLINTCOL#', NUMBER(asdecimal=False))
    ACDRRESCOL_: Mapped[Optional[float]] = mapped_column('ACDRRESCOL#', NUMBER(asdecimal=False))


class LogmnrcGtlo(Base):
    __tablename__ = 'logmnrc_gtlo'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'KEYOBJ#', 'BASEOBJV#', name='logmnrc_gtlo_pk'),
        Index('logmnrc_i2gtlo', 'logmnr_uid', 'BASEOBJ#', 'BASEOBJV#'),
        Index('logmnrc_i3gtlo', 'logmnr_uid', 'drop_scn'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    KEYOBJ_: Mapped[float] = mapped_column('KEYOBJ#', NUMBER(asdecimal=False), primary_key=True)
    lvlcnt: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    BASEOBJ_: Mapped[float] = mapped_column('BASEOBJ#', NUMBER(asdecimal=False), nullable=False)
    BASEOBJV_: Mapped[float] = mapped_column('BASEOBJV#', NUMBER(asdecimal=False), primary_key=True)
    LVL0TYPE_: Mapped[float] = mapped_column('LVL0TYPE#', NUMBER(asdecimal=False), nullable=False)
    ownername: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    lvl0name: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    intcols: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    start_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    LVL1OBJ_: Mapped[Optional[float]] = mapped_column('LVL1OBJ#', NUMBER(asdecimal=False))
    LVL2OBJ_: Mapped[Optional[float]] = mapped_column('LVL2OBJ#', NUMBER(asdecimal=False))
    LVL1TYPE_: Mapped[Optional[float]] = mapped_column('LVL1TYPE#', NUMBER(asdecimal=False))
    LVL2TYPE_: Mapped[Optional[float]] = mapped_column('LVL2TYPE#', NUMBER(asdecimal=False))
    OWNER_: Mapped[Optional[float]] = mapped_column('OWNER#', NUMBER(asdecimal=False))
    lvl1name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    lvl2name: Mapped[Optional[str]] = mapped_column(VARCHAR(384))
    cols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    kernelcols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    tab_flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    trigflag: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    ASSOC_: Mapped[Optional[float]] = mapped_column('ASSOC#', NUMBER(asdecimal=False))
    obj_flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    TS_: Mapped[Optional[float]] = mapped_column('TS#', NUMBER(asdecimal=False))
    tsname: Mapped[Optional[str]] = mapped_column(VARCHAR(90))
    property: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xidusn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xidslt: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    xidsqn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    flags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(1000))
    logmnr_spare4: Mapped[Optional[datetime.datetime]] = mapped_column(DateTime)
    logmnr_spare5: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare6: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare7: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare8: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnr_spare9: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    parttype: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    subparttype: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    unsupportedcols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    complextypecols: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    ntparentobjnum: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    ntparentobjversion: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    ntparentintcolnum: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnrtloflags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    logmnrmcv: Mapped[Optional[str]] = mapped_column(VARCHAR(30))
    acdrflags: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    ACDRTSOBJ_: Mapped[Optional[float]] = mapped_column('ACDRTSOBJ#', NUMBER(asdecimal=False))
    ACDRROWTSINTCOL_: Mapped[Optional[float]] = mapped_column('ACDRROWTSINTCOL#', NUMBER(asdecimal=False))


class LogmnrcIndGg(Base):
    __tablename__ = 'logmnrc_ind_gg'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'commit_scn', name='logmnrc_ind_gg_pk'),
        Index('logmnrc_i1indgg', 'logmnr_uid', 'BASEOBJ#', 'BASEOBJV#', 'commit_scn'),
        Index('logmnrc_i2indgg', 'logmnr_uid', 'drop_scn'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    name: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    commit_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    BASEOBJ_: Mapped[float] = mapped_column('BASEOBJ#', NUMBER(asdecimal=False), nullable=False)
    BASEOBJV_: Mapped[float] = mapped_column('BASEOBJV#', NUMBER(asdecimal=False), nullable=False)
    flags: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    OWNER_: Mapped[float] = mapped_column('OWNER#', NUMBER(asdecimal=False), nullable=False)
    ownername: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare4: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    spare5: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    spare6: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrcIndcolGg(Base):
    __tablename__ = 'logmnrc_indcol_gg'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'commit_scn', 'INTCOL#', name='logmnrc_indcol_gg_pk'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    commit_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    INTCOL_: Mapped[float] = mapped_column('INTCOL#', NUMBER(asdecimal=False), primary_key=True)
    POS_: Mapped[float] = mapped_column('POS#', NUMBER(asdecimal=False), nullable=False)
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrcSeqGg(Base):
    __tablename__ = 'logmnrc_seq_gg'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'commit_scn', name='logmnrc_seq_gg_pk'),
        Index('logmnrc_i2seqgg', 'logmnr_uid', 'drop_scn'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    commit_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    seq_flags: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    OWNER_: Mapped[float] = mapped_column('OWNER#', NUMBER(asdecimal=False), nullable=False)
    ownername: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    objname: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    seqcache: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    seqinc: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))
    spare4: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrcShardTs(Base):
    __tablename__ = 'logmnrc_shard_ts'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'tablespace_name', 'start_scn', name='logmnrc_shard_ts_pk'),
        Index('logmnrc_i1shard_ts', 'logmnr_uid', 'drop_scn'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    tablespace_name: Mapped[str] = mapped_column(VARCHAR(90), primary_key=True)
    chunk_number: Mapped[float] = mapped_column(NUMBER(asdecimal=False), nullable=False)
    start_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrcTs(Base):
    __tablename__ = 'logmnrc_ts'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'TS#', 'start_scn', name='logmnrc_ts_pk'),
        Index('logmnrc_i1ts', 'logmnr_uid', 'drop_scn'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    TS_: Mapped[float] = mapped_column('TS#', NUMBER(22, 0, False), primary_key=True)
    start_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    name: Mapped[Optional[str]] = mapped_column(VARCHAR(90))
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrcTspart(Base):
    __tablename__ = 'logmnrc_tspart'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'OBJ#', 'start_scn', name='logmnrc_tspart_pk'),
        Index('logmnrc_i1tspart', 'logmnr_uid', 'drop_scn'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    OBJ_: Mapped[float] = mapped_column('OBJ#', NUMBER(asdecimal=False), primary_key=True)
    TS_: Mapped[float] = mapped_column('TS#', NUMBER(asdecimal=False), nullable=False)
    start_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrcUser(Base):
    __tablename__ = 'logmnrc_user'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'USER#', 'start_scn', name='logmnrc_user_pk'),
        Index('logmnrc_i1user', 'logmnr_uid', 'name', 'start_scn'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    USER_: Mapped[float] = mapped_column('USER#', NUMBER(22, 0, False), primary_key=True)
    name: Mapped[str] = mapped_column(VARCHAR(384), nullable=False)
    start_scn: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    drop_scn: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare1_c: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2_c: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3_c: Mapped[Optional[str]] = mapped_column(VARCHAR(4000))


class LogmnrpCtasPartMap(Base):
    __tablename__ = 'logmnrp_ctas_part_map'
    __table_args__ = (
        PrimaryKeyConstraint('logmnr_uid', 'BASEOBJV#', 'KEYOBJ#', name='logmnrp_ctas_part_map_pk'),
        Index('logmnrp_ctas_part_map_i', 'logmnr_uid', 'BASEOBJ#', 'BASEOBJV#', 'PART#'),
        {'schema': 'SYSTEM'}
    )

    logmnr_uid: Mapped[float] = mapped_column(NUMBER(asdecimal=False), primary_key=True)
    BASEOBJ_: Mapped[float] = mapped_column('BASEOBJ#', NUMBER(asdecimal=False), nullable=False)
    BASEOBJV_: Mapped[float] = mapped_column('BASEOBJV#', NUMBER(asdecimal=False), primary_key=True)
    KEYOBJ_: Mapped[float] = mapped_column('KEYOBJ#', NUMBER(asdecimal=False), primary_key=True)
    PART_: Mapped[float] = mapped_column('PART#', NUMBER(asdecimal=False), nullable=False)
    spare1: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare2: Mapped[Optional[float]] = mapped_column(NUMBER(asdecimal=False))
    spare3: Mapped[Optional[str]] = mapped_column(VARCHAR(1000))


t_logstdby_apply_progress = Table(
    'logstdby$apply_progress', Base.metadata,
    Column('xidusn', NUMBER(asdecimal=False)),
    Column('xidslt', NUMBER(asdecimal=False)),
    Column('xidsqn', NUMBER(asdecimal=False)),
    Column('commit_scn', NUMBER(asdecimal=False)),
    Column('commit_time', DateTime),
    Column('spare1', NUMBER(asdecimal=False)),
    Column('spare2', NUMBER(asdecimal=False)),
    Column('spare3', VARCHAR(2000)),
    schema='SYSTEM'
)


t_mview_evaluations = Table(
    'mview_evaluations', Base.metadata,
    Column('runid', NUMBER(asdecimal=False), nullable=False),
    Column('mview_owner', VARCHAR(128)),
    Column('mview_name', VARCHAR(128)),
    Column('rank', NUMBER(asdecimal=False), nullable=False),
    Column('storage_in_bytes', NUMBER(asdecimal=False)),
    Column('frequency', NUMBER(asdecimal=False)),
    Column('cumulative_benefit', NUMBER(asdecimal=False)),
    Column('benefit_to_cost_ratio', NUMBER(asdecimal=False), nullable=False),
    schema='SYSTEM',
    comment='This view gives DBA access to summary evaluation output'
)


t_mview_exceptions = Table(
    'mview_exceptions', Base.metadata,
    Column('runid', NUMBER(asdecimal=False)),
    Column('owner', VARCHAR(128)),
    Column('table_name', VARCHAR(128)),
    Column('dimension_name', VARCHAR(128)),
    Column('relationship', VARCHAR(11)),
    Column('bad_rowid', ROWID),
    schema='SYSTEM',
    comment='This view gives DBA access to dimension validation results'
)


t_mview_filter = Table(
    'mview_filter', Base.metadata,
    Column('filterid', NUMBER(asdecimal=False), nullable=False),
    Column('subfilternum', NUMBER(asdecimal=False), nullable=False),
    Column('subfiltertype', VARCHAR(12)),
    Column('str_value', VARCHAR(1028)),
    Column('num_value1', NUMBER(asdecimal=False)),
    Column('num_value2', NUMBER(asdecimal=False)),
    Column('date_value1', DateTime),
    Column('date_value2', DateTime),
    schema='SYSTEM',
    comment='Workload filter records'
)


t_mview_filterinstance = Table(
    'mview_filterinstance', Base.metadata,
    Column('runid', NUMBER(asdecimal=False), nullable=False),
    Column('filterid', NUMBER(asdecimal=False)),
    Column('subfilternum', NUMBER(asdecimal=False)),
    Column('subfiltertype', VARCHAR(12)),
    Column('str_value', VARCHAR(1028)),
    Column('num_value1', NUMBER(asdecimal=False)),
    Column('num_value2', NUMBER(asdecimal=False)),
    Column('date_value1', DateTime),
    Column('date_value2', DateTime),
    schema='SYSTEM',
    comment='Workload filter instance records'
)


t_mview_log = Table(
    'mview_log', Base.metadata,
    Column('id', NUMBER(asdecimal=False), nullable=False),
    Column('filterid', NUMBER(asdecimal=False)),
    Column('run_begin', DateTime),
    Column('run_end', DateTime),
    Column('type', VARCHAR(11)),
    Column('status', VARCHAR(11)),
    Column('message', VARCHAR(2000)),
    Column('completed', NUMBER(asdecimal=False)),
    Column('total', NUMBER(asdecimal=False)),
    Column('error_code', VARCHAR(20)),
    schema='SYSTEM',
    comment='Advisor session log'
)


t_mview_recommendations = Table(
    'mview_recommendations', Base.metadata,
    Column('runid', NUMBER(asdecimal=False), nullable=False),
    Column('all_tables', VARCHAR(2000)),
    Column('fact_tables', VARCHAR(1000)),
    Column('grouping_levels', VARCHAR(2000)),
    Column('query_text', LONG),
    Column('recommendation_number', NUMBER(asdecimal=False), nullable=False),
    Column('recommended_action', VARCHAR(6)),
    Column('mview_owner', VARCHAR(128)),
    Column('mview_name', VARCHAR(128)),
    Column('storage_in_bytes', NUMBER(asdecimal=False)),
    Column('pct_performance_gain', NUMBER(asdecimal=False)),
    Column('benefit_to_cost_ratio', NUMBER(asdecimal=False), nullable=False),
    schema='SYSTEM',
    comment='This view gives DBA access to summary recommendations'
)


t_mview_workload = Table(
    'mview_workload', Base.metadata,
    Column('workloadid', NUMBER(asdecimal=False), nullable=False),
    Column('import_time', DateTime, nullable=False),
    Column('queryid', NUMBER(asdecimal=False), nullable=False),
    Column('application', VARCHAR(128)),
    Column('cardinality', NUMBER(asdecimal=False)),
    Column('resultsize', NUMBER(asdecimal=False)),
    Column('lastuse', DateTime),
    Column('frequency', NUMBER(asdecimal=False)),
    Column('owner', VARCHAR(128), nullable=False),
    Column('priority', NUMBER(asdecimal=False)),
    Column('query', LONG, nullable=False),
    Column('responsetime', NUMBER(asdecimal=False)),
    schema='SYSTEM',
    comment='This view gives DBA access to shared workload'
)


t_product_privs = Table(
    'product_privs', Base.metadata,
    Column('product', VARCHAR(30), nullable=False),
    Column('userid', VARCHAR(128)),
    Column('attribute', VARCHAR(240)),
    Column('scope', VARCHAR(240)),
    Column('numeric_value', NUMBER(15, 2, True)),
    Column('char_value', VARCHAR(240)),
    Column('date_value', DateTime),
    Column('long_value', LONG),
    schema='SYSTEM'
)


t_scheduler_job_args = Table(
    'scheduler_job_args', Base.metadata,
    Column('owner', VARCHAR(128)),
    Column('job_name', VARCHAR(128)),
    Column('argument_name', VARCHAR(128)),
    Column('argument_position', NUMBER(asdecimal=False)),
    Column('argument_type', VARCHAR(257)),
    Column('value', VARCHAR(4000)),
    Column('anydata_value', NullType),
    Column('out_argument', VARCHAR(5)),
    schema='SYSTEM'
)


t_scheduler_program_args = Table(
    'scheduler_program_args', Base.metadata,
    Column('owner', VARCHAR(128), nullable=False),
    Column('program_name', VARCHAR(128), nullable=False),
    Column('argument_name', VARCHAR(128)),
    Column('argument_position', NUMBER(asdecimal=False), nullable=False),
    Column('argument_type', VARCHAR(257)),
    Column('metadata_attribute', VARCHAR(19)),
    Column('default_value', VARCHAR(4000)),
    Column('default_anydata_value', NullType),
    Column('out_argument', VARCHAR(5)),
    schema='SYSTEM'
)


t_v_material_availability = Table(
    'v_material_availability', Base.metadata,
    Column('material_id', NUMBER(asdecimal=False), nullable=False),
    Column('title', VARCHAR(200), nullable=False),
    Column('material_type', VARCHAR(30), nullable=False),
    Column('total_copies', NUMBER(asdecimal=False)),
    Column('available_copies', NUMBER(asdecimal=False)),
    Column('reservations_count', NUMBER(asdecimal=False)),
    Column('availability_status', VARCHAR(58)),
    schema='SYSTEM'
)


t_v_overdue_loans = Table(
    'v_overdue_loans', Base.metadata,
    Column('loan_id', NUMBER(asdecimal=False), nullable=False),
    Column('checkout_date', DateTime, nullable=False),
    Column('due_date', DateTime, nullable=False),
    Column('days_overdue', NUMBER(asdecimal=False)),
    Column('patron_id', NUMBER(asdecimal=False), nullable=False),
    Column('patron_name', VARCHAR(101)),
    Column('patron_email', VARCHAR(100)),
    Column('material_title', VARCHAR(200), nullable=False),
    Column('copy_barcode', VARCHAR(50), nullable=False),
    Column('branch_name', VARCHAR(100), nullable=False),
    schema='SYSTEM'
)


t_v_patron_statistics = Table(
    'v_patron_statistics', Base.metadata,
    Column('patron_id', NUMBER(asdecimal=False), nullable=False),
    Column('patron_name', VARCHAR(101)),
    Column('card_number', VARCHAR(20), nullable=False),
    Column('account_status', VARCHAR(20)),
    Column('total_loans', NUMBER(asdecimal=False)),
    Column('active_loans', NUMBER(asdecimal=False)),
    Column('overdue_loans', NUMBER(asdecimal=False)),
    Column('total_fines_owed', NUMBER(10, 2, True)),
    Column('active_reservations', NUMBER(asdecimal=False)),
    schema='SYSTEM'
)
