class DimError(Exception):
    code = 1


error_types = dict(
    InvalidPoolError=2,
    InvalidIPError=3,
    InvalidVLANError=4,
    InvalidStatusError=5,
    InvalidPriorityError=6,
    InvalidGroupError=7,
    InvalidUserError=8,
    InvalidAccessRightError=9,
    InvalidZoneError=10,
    InvalidViewError=11,
    MultipleViewsError=12,
    InvalidParameterError=19,
    AlreadyExistsError=20,
    NotInPoolError=21,
    NotInDelegationError=22,
    PermissionDeniedError=23,
    HasChildrenError=24,
)
for name, code in list(error_types.items()):
    globals()[name] = type(name, (DimError,), {'code': code})
