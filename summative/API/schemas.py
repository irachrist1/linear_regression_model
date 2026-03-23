from __future__ import annotations

from enum import Enum

from pydantic import BaseModel, Field


class GenderEnum(str, Enum):
    M = "M"
    F = "F"


class DisabilityEnum(str, Enum):
    N = "N"
    Y = "Y"


class RegionEnum(str, Enum):
    EAST_ANGLIAN = "East Anglian Region"
    EAST_MIDLANDS = "East Midlands Region"
    IRELAND = "Ireland"
    LONDON = "London Region"
    NORTH = "North Region"
    NORTH_WESTERN = "North Western Region"
    SCOTLAND = "Scotland"
    SOUTH_EAST = "South East Region"
    SOUTH = "South Region"
    SOUTH_WEST = "South West Region"
    WALES = "Wales"
    WEST_MIDLANDS = "West Midlands Region"
    YORKSHIRE = "Yorkshire Region"


class HighestEducationEnum(str, Enum):
    NO_FORMAL = "No Formal quals"
    LOWER_THAN_A_LEVEL = "Lower Than A Level"
    A_LEVEL = "A Level or Equivalent"
    HE_QUALIFICATION = "HE Qualification"
    POST_GRADUATE = "Post Graduate Qualification"


class ImdBandEnum(str, Enum):
    BAND_0_10 = "0-10%"
    BAND_10_20 = "10-20"
    BAND_20_30 = "20-30%"
    BAND_30_40 = "30-40%"
    BAND_40_50 = "40-50%"
    BAND_50_60 = "50-60%"
    BAND_60_70 = "60-70%"
    BAND_70_80 = "70-80%"
    BAND_80_90 = "80-90%"
    BAND_90_100 = "90-100%"


class AgeBandEnum(str, Enum):
    AGE_0_35 = "0-35"
    AGE_35_55 = "35-55"
    AGE_55_PLUS = "55<="


class PredictionInput(BaseModel):
    gender: GenderEnum
    region: RegionEnum
    highest_education: HighestEducationEnum
    imd_band: ImdBandEnum
    age_band: AgeBandEnum
    num_of_prev_attempts: int = Field(ge=0, le=6)
    studied_credits: int = Field(ge=30, le=630)
    disability: DisabilityEnum
    date_registration: float = Field(ge=-311, le=167)
    total_clicks: float = Field(ge=0, le=24139)


class PredictionResponse(BaseModel):
    predicted_avg_score: float
    performance_band: str
    model_name: str
    engineered_features: dict[str, float]


class RetrainSample(BaseModel):
    features: PredictionInput
    actual_avg_score: float = Field(ge=0, le=100)


class RetrainSubmitResponse(BaseModel):
    status: str
    buffered_samples: int

