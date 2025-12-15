import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import pandas as pd

# Reuse the same helper functions from compare_grids.py
# Note: Both scripts are in the same directory (Benchmarking/)
# If running from the root directory, add Benchmarking to path:
# import sys
# from pathlib import Path
# sys.path.insert(0, str(Path(__file__).parent))
from compare_grids import load_eedf, load_swarm_params, load_rate_coeffs, load_power_balance, plot_parameter_evolution, plot_relative_difference

def collect_all_data_highfields(base_path):
    """Collect data from all reduced field folders for high fields"""
    data = {
        'reduced_fields': [],
        'swarm_params': {'variable': {}, 'uniform': {}},
        'rate_coeffs': {'variable': {}, 'uniform': {}},
        'power_balance': {'variable': {}, 'uniform': {}}
    }

    # Get all reduced field folders
    var_path = base_path / 'H2Swarm_highField'
    unif_path = base_path / 'H2Swarm_highField_unif'

    # Get list of all reduced field folders
    field_folders = [d for d in var_path.iterdir() if d.is_dir() and d.name.startswith('reducedField_')]

    # Sort folders by reduced field value
    field_folders.sort(key=lambda x: float(x.name.split('_')[1]))

    for folder in field_folders:
        field_value = float(folder.name.split('_')[1])
        data['reduced_fields'].append(field_value)

        try:
            # Load data for variable grid
            var_swarm = load_swarm_params(folder / 'swarmParameters.txt')
            var_rates = load_rate_coeffs(folder / 'rateCoefficients.txt')
            var_power = load_power_balance(folder / 'powerBalance.txt')

            # Load data for uniform grid
            unif_folder = unif_path / folder.name
            unif_swarm = load_swarm_params(unif_folder / 'swarmParameters.txt')
            unif_rates = load_rate_coeffs(unif_folder / 'rateCoefficients.txt')
            unif_power = load_power_balance(unif_folder / 'powerBalance.txt')

            # Store swarm parameters
            for param in var_swarm:
                if param not in data['swarm_params']['variable']:
                    data['swarm_params']['variable'][param] = []
                    data['swarm_params']['uniform'][param] = []
                data['swarm_params']['variable'][param].append(var_swarm[param])
                data['swarm_params']['uniform'][param].append(unif_swarm[param])

            # Store rate coefficients
            for rate in var_rates:
                if rate not in data['rate_coeffs']['variable']:
                    data['rate_coeffs']['variable'][rate] = []
                    data['rate_coeffs']['uniform'][rate] = []
                data['rate_coeffs']['variable'][rate].append(var_rates[rate])
                data['rate_coeffs']['uniform'][rate].append(unif_rates[rate])

            # Store power balance
            for power_term in var_power:
                if power_term not in data['power_balance']['variable']:
                    data['power_balance']['variable'][power_term] = []
                    data['power_balance']['uniform'][power_term] = []
                data['power_balance']['variable'][power_term].append(var_power[power_term])
                data['power_balance']['uniform'][power_term].append(unif_power[power_term])

        except Exception as e:
            print(f"Error processing folder {folder.name}: {str(e)}")
            continue

    return data

def main():
    # Create plots directory if it doesn't exist
    plots_dir = Path('plots_HF')
    plots_dir.mkdir(exist_ok=True)

    # Define paths and collect all data
    base_path = Path('Output')
    data = collect_all_data_highfields(base_path)

    # Plot swarm parameters evolution
    swarm_params = ['Mean energy', 'Drift velocity', 'Reduced diffusion coefficient']
    fig = plot_parameter_evolution(data, 'swarm_params', swarm_params, 
                                 'Swarm Parameters vs Reduced Field (High Fields)',
                                 'Parameter Value', log_y=True)
    plt.savefig(plots_dir / 'swarm_params_evolution_highfields.png', dpi=300, bbox_inches='tight')
    plt.close()

    # Plot relative differences for swarm parameters
    fig = plot_relative_difference(data, 'swarm_params', swarm_params,
                                 'Relative Difference in Swarm Parameters (High Fields)')
    plt.savefig(plots_dir / 'swarm_params_difference_highfields.png', dpi=300, bbox_inches='tight')
    plt.close()

    # Plot rate coefficients evolution
    rate_coeffs = list(data['rate_coeffs']['variable'].keys())
    if rate_coeffs:  # Only plot if we have rate coefficients
        fig = plot_parameter_evolution(data, 'rate_coeffs', rate_coeffs,
                                     'Rate Coefficients vs Reduced Field (High Fields)',
                                     'Rate Coefficient (m³s⁻¹)', log_y=True)
        plt.savefig(plots_dir / 'rate_coeffs_evolution_highfields.png', dpi=300, bbox_inches='tight')
        plt.close()

    # Plot power balance terms evolution
    power_terms = ['Field', 'Elastic collisions (net)', 'CAR (net)', 'Excitation collisions (net)']
    if any(term in data['power_balance']['variable'] for term in power_terms):  # Only plot if we have power terms
        fig = plot_parameter_evolution(data, 'power_balance', power_terms,
                                     'Power Balance Terms vs Reduced Field (High Fields)',
                                     'Power (eVm³s⁻¹)', log_y=True)
        plt.savefig(plots_dir / 'power_balance_evolution_highfields.png', dpi=300, bbox_inches='tight')
        plt.close()

        # Plot relative differences for power balance
        fig = plot_relative_difference(data, 'power_balance', power_terms,
                                     'Relative Difference in Power Balance Terms (High Fields)')
        plt.savefig(plots_dir / 'power_balance_difference_highfields.png', dpi=300, bbox_inches='tight')
        plt.close()

if __name__ == '__main__':
    main()