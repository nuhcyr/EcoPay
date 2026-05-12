package com.ecopay.entity;

public enum ActivityType {
    CAR,
    BUS,
    BIKE,
    WALK,
    /** Toplu taşıma — raylı */
    METRO,
    /** Şehirler arası / banliyö tren */
    TRAIN,
    /** Elektrikli scooter / hafif EV */
    E_SCOOTER,
    /** Elektrikli otomobil (şarj emisyonu — gösterim amaçlı katsayı) */
    EV_CAR
}
