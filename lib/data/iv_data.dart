import '../models/capacity_option.dart';
import '../models/fluid_group.dart';

//data information file

const List<CapacityOption> kCapacities = [
  CapacityOption(100),
  CapacityOption(250),
  CapacityOption(500),
  CapacityOption(1000),
];

const List<FluidGroup> kFluidGroups = [
  FluidGroup('Intravenous Sodium Chloride Solutions', [
    'Half Normal Saline (0.45% NaCl)',
    'Normal Saline (0.9% NaCl)',
    'Hypertonic Saline (3% NaCl)',
    'Hypertonic Saline (5% NaCl)',
    'Hypertonic Saline (7.5% NaCl)',
  ]),
  FluidGroup('Intravenous Ringer\u2019s Solutions', [
    "Lactated Ringer's (Hartmann)",
    "Acetated Ringer's",
    "Lactated Ringer's + Dextrose 5%",
    "Acetated Ringer's + Dextrose 5%",
  ]),
  FluidGroup('Intravenous Dextrose Solutions', [
    'D5W (Dextrose 5% in Water)',
    'D10W (Dextrose 10% in Water)',
    'D20W (Dextrose 20% in Water)',
  ]),
  FluidGroup('Combined Dextrose and Sodium Chloride Solutions', [
    'D5 1/2NS (D5 in 0.45% Saline)',
    'D5NS (D5 in Normal Saline)',
    'D10NS (D10 in Normal Saline)',
  ]),
  FluidGroup('Intravenous Mannitol Solutions', [
    'Mannitol 5%',
    'Mannitol 10%',
    'Mannitol 15%',
    'Mannitol 20%',
  ]),
  FluidGroup('Intravenous Multiple Electrolyte Solutions', [
    'Plasma-Lyte A',
    'Plasma-Lyte + Dextrose 5%',
    "Hartmann's",
  ]),
  FluidGroup('Additional', [
    'Dextran 40 10% in Saline',
    'Dextran 70 6% in Saline',
    'Hydroxyethyl Starch 6% (HES 6%)',
  ]),
];