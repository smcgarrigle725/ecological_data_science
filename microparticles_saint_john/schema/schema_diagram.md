# Schema Diagram

---

## Entity-Relationship Overview

```
                          ┌───────────────────────────┐
                          │           Site            │
                          │---------------------------|
                          │ PK: siteid                │
                          │     collection_organization│
                          │     primarycontact        │
                          │     year                  │
                          │     waterbody             │
                          │     waterbodytype         │
                          │     site                  │
                          │     latitude              │
                          │     longitude             │
                          │     substrate             │
                          │     benthicpelagic        │
                          │     tidaldepth            │
                          │     samplestaken          │
                          │     sampletypes           │
                          └─────────────┬─────────────┘
                                        │ siteid
              ┌─────────────────────────┼─────────────────────────┐
              │                         │                         │
              ▼                         ▼                         ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│       Animal        │   │      Sediment        │   │        Water        │
│---------------------|   │---------------------|   │---------------------|
│ PK: id              │   │ PK: id              │   │ PK: id              │
│ GSI: siteid         │   │ GSI: siteid         │   │ GSI: siteid         │
│     sampleid        │   │     sampleid        │   │     sampleid        │
│     collection_org  │   │     collection_org  │   │     collection_org  │
│     primarycontact  │   │     primarycontact  │   │     primarycontact  │
│     site            │   │     site            │   │     site            │
│     year            │   │     year            │   │     year            │
│     date            │   │     date            │   │     date            │
│     processingmethod│   │     processingmethod│   │     processingmethod│
│     species_common  │   │     sampleweight_wwt│   │     samplevolume    │
│     species_sci     │   │     totalmp         │   │     totalmp         │
│     number_animal   │   │     fibre           │   │     fibre           │
│     sampleweight    │   │     fragment        │   │     fragment        │
│     animallength    │   │     sphere          │   │     sphere          │
│     tissuetype      │   │     film            │   │     film            │
│     totalmp         │   │     ftir_complete   │   │     ftir_complete   │
│     fibre           │   │     ftir_numbersent │   │     ftir_numbersent │
│     fragment        │   └──────────┬──────────┘   └──────────┬──────────┘
│     sphere          │              │                          │
│     film            │              │ id                       │ id
│     ftir_complete   │              │                          │
│     ftir_numbersent │              │                          │
└──────────┬──────────┘              │                          │
           │ id                      │                          │
           └────────────────────────┬┘──────────────────────────┘
                                    │
                                    ▼
                     ┌──────────────────────────┐
                     │           FTIR           │
                     │--------------------------|
                     │ PK: mp_id                │
                     │ GSI: id                  │
                     │     sampleid             │
                     │     collection_org       │
                     │     primarycontact       │
                     │     date                 │
                     │     common_plastic       │
                     │     ftir_primary         │
                     │     ftir_secondary       │
                     │     ftir_tertiary        │
                     │     ftir_quarternary     │
                     │     ftir_quinary         │
                     │     cellulosic_peak      │
                     │     ftir_size_microns    │
                     │     colour               │
                     │     other_colour         │
                     │     structure            │
                     │     filename             │
                     └──────────────────────────┘
```

---

## Key Relationships

| Relationship | Join On | Type |
|-------------|---------|------|
| Site → Animal | `Site.siteid = Animal.siteid` | One-to-many |
| Site → Sediment | `Site.siteid = Sediment.siteid` | One-to-many |
| Site → Water | `Site.siteid = Water.siteid` | One-to-many |
| Animal → FTIR | `Animal.id = FTIR.id` | One-to-many |
| Sediment → FTIR | `Sediment.id = FTIR.id` | One-to-many |
| Water → FTIR | `Water.id = FTIR.id` | One-to-many |

---

## ID Format Reference

| Table | Partition Key | Format | Example |
|-------|--------------|--------|---------|
| Site | `siteid` | `Year_Site_SampleType` | `2022_HarbourNorth_Animal` |
| Animal | `id` | `Year_Site_Animal_sampleid` | `2022_HarbourNorth_Animal_S01` |
| Sediment | `id` | `Year_Site_Sediment_sampleid` | `2022_HarbourNorth_Sediment_S01` |
| Water | `id` | `Year_Site_Water_sampleid` | `2022_HarbourNorth_Water_S01` |
| FTIR | `mp_id` | `parent_id_XX` | `2022_HarbourNorth_Animal_S01_03` |

---

## Access Patterns Supported

| Query | Method |
|-------|--------|
| All sites | Scan `Site` |
| All sites on a given waterbody | Query `Site` GSI `waterbody-index` |
| All animal samples at a site | Query `Animal` GSI `siteid-index` |
| All sediment samples at a site | Query `Sediment` GSI `siteid-index` |
| All water samples at a site | Query `Water` GSI `siteid-index` |
| All FTIR results for a sample | Query `FTIR` GSI `id-index` |
| Full record: Site + Animal + FTIR | Three queries joined client-side on `siteid` and `id` |
| All samples across matrices (long format) | Scan Water + Sediment + Animal, union client-side |

---

## Notes on FTIR Linkage

FTIR records link to their parent sample via the `id` field, which matches the partition key of whichever sample table (Animal, Sediment, or Water) the MP originated from. The FTIR table does not include a `sample_type` field because MPs were randomly selected for spectroscopic analysis across samples and the originating matrix was not recorded at the time of lab submission. If the matrix type is needed, it can be inferred from the structure of the `id` string (e.g., a value containing `_Animal_` originated from the Animal table).