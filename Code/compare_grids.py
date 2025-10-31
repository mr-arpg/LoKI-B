import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path
import pandas as pd

def load_eedf(file_path):
    """Load EEDF data from file"""
    data = np.loadtxt(file_path, skiprows=1)
    energy = data[:, 0]
    eedf = data[:, 1]
    return energy, eedf

def load_swarm_params(file_path):
    """Load swarm parameters from file"""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    params = {}
    for line in lines[1:]:  # Skip header
        if '=' in line:
            key, value = line.split('=')
            # Extract the value and unit
            value = value.split('(')[0].strip()
            params[key.strip()] = float(value)
    return params

def load_rate_coeffs(file_path):
    """Load rate coefficients from file"""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    # Skip header lines
    start_idx = 0
    for i, line in enumerate(lines):
        if 'ID' in line and 'Ine.R.Coeff.' in line:
            start_idx = i + 1
            break
    
    coeffs = {}
    for line in lines[start_idx:]:
        if line.strip():  # Skip empty lines
            parts = line.split()
            if len(parts) >= 5:  # Make sure we have enough parts
                # Get the description (last part) and the inelastic rate coefficient (second part)
                desc = ' '.join(parts[4:])
                rate = float(parts[1])
                coeffs[desc] = rate
    
    return coeffs

def load_power_balance(file_path):
    """Load power balance data from file"""
    with open(file_path, 'r') as f:
        lines = f.readlines()
    power = {}
    
    # First pass: collect all individual terms
    for line in lines[1:]:  # Skip header
        if '=' in line and not line.startswith('--'):  # Skip separator lines
            key, value = line.split('=')
            # Extract the value and remove unit and % if present
            value = value.split('(')[0].strip()
            value = value.rstrip('%')  # Remove % if present
            try:
                power[key.strip()] = float(value)
            except ValueError:
                print(f"Warning: Could not convert value '{value}' to float for key '{key.strip()}'")
    
    # Second pass: collect net terms
    for i, line in enumerate(lines):
        if 'net' in line and '=' in line:
            key, value = line.split('=')
            # Extract the value and remove unit and % if present
            value = value.split('(')[0].strip()
            value = value.rstrip('%')  # Remove % if present
            try:
                power[key.strip()] = float(value)
            except ValueError:
                print(f"Warning: Could not convert value '{value}' to float for key '{key.strip()}'")
    
    return power

def collect_all_data(base_path):
    """Collect data from all reduced field folders"""
    data = {
        'reduced_fields': [],
        'swarm_params': {'variable': {}, 'uniform': {}},
        'rate_coeffs': {'variable': {}, 'uniform': {}},
        'power_balance': {'variable': {}, 'uniform': {}}
    }
    
    # Get all reduced field folders
    var_path = base_path / 'H2Swarm_lowField'
    unif_path = base_path / 'H2Swarm_lowField_unif'
    
    # Get list of all reduced field folders
    field_folders = [d for d in var_path.iterdir() if d.is_dir() and d.name.startswith('reducedField_')]
    
    # Sort folders by reduced field value
    field_folders.sort(key=lambda x: float(x.name.split('_')[1]))
    
    # Debug: Print first folder's power balance data
    first_folder = field_folders[0]
    print("\nPower balance data from first folder:")
    var_power = load_power_balance(first_folder / 'powerBalance.txt')
    print("Variable grid power terms:", list(var_power.keys()))
    print("Variable grid power values:", {k: v for k, v in var_power.items() if 'net' in k})
    
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
    
    # Debug: Print final power balance data
    print("\nFinal power balance data:")
    print("Available power terms:", list(data['power_balance']['variable'].keys()))
    print("Sample values for net terms:")
    for term in data['power_balance']['variable']:
        if 'net' in term:
            print(f"{term}:")
            print("  Variable grid:", data['power_balance']['variable'][term][:5])
            print("  Uniform grid:", data['power_balance']['uniform'][term][:5])
    
    return data

def plot_parameter_evolution(data, param_type, params_to_plot, title, ylabel, log_x=True, log_y=False):
    """Create evolution plot for specified parameters"""
    plt.figure(figsize=(12, 8))
    
    for param in params_to_plot:
        if param in data[param_type]['variable']:
            var_data = np.abs(np.array(data[param_type]['variable'][param]))  # Use absolute values
            unif_data = np.abs(np.array(data[param_type]['uniform'][param]))  # Use absolute values
            
            plt.plot(data['reduced_fields'], var_data, 'b-', label=f'Variable Grid - {param}')
            plt.plot(data['reduced_fields'], unif_data, 'r--', label=f'Uniform Grid - {param}')
    
    if log_x:
        plt.xscale('log')
    if log_y:
        plt.yscale('log')
    
    plt.xlabel('Reduced Field (Td)')
    plt.ylabel(ylabel)
    plt.title(title)
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.grid(True)
    plt.tight_layout()
    return plt.gcf()

def plot_relative_difference(data, param_type, params_to_plot, title, log_x=True):
    """Create relative difference plot between variable and uniform grid"""
    plt.figure(figsize=(12, 8))
    
    for param in params_to_plot:
        if param in data[param_type]['variable']:
            var_data = np.array(data[param_type]['variable'][param])
            unif_data = np.array(data[param_type]['uniform'][param])
            
            # Use absolute values for the difference
            rel_diff = np.abs(100 * (var_data - unif_data) / unif_data)
            plt.plot(data['reduced_fields'], rel_diff, '-', label=param)
    
    if log_x:
        plt.xscale('log')
    
    plt.xlabel('Reduced Field (Td)')
    plt.ylabel('Absolute Relative Difference (%)')
    plt.title(title)
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.grid(True)
    plt.tight_layout()
    return plt.gcf()

def main():
    # Create plots directory if it doesn't exist
    plots_dir = Path('plots')
    plots_dir.mkdir(exist_ok=True)
    
    # Define paths and collect all data
    base_path = Path('Output')
    data = collect_all_data(base_path)
    
    # Plot swarm parameters evolution
    swarm_params = ['Mean energy', 'Drift velocity', 'Reduced diffusion coefficient']
    fig = plot_parameter_evolution(data, 'swarm_params', swarm_params, 
                                 'Swarm Parameters vs Reduced Field',
                                 'Parameter Value', log_y=True)
    plt.savefig(plots_dir / 'swarm_params_evolution.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # Plot relative differences for swarm parameters
    fig = plot_relative_difference(data, 'swarm_params', swarm_params,
                                 'Relative Difference in Swarm Parameters')
    plt.savefig(plots_dir / 'swarm_params_difference.png', dpi=300, bbox_inches='tight')
    plt.close()
    
    # Plot rate coefficients evolution
    rate_coeffs = list(data['rate_coeffs']['variable'].keys())
    if rate_coeffs:  # Only plot if we have rate coefficients
        fig = plot_parameter_evolution(data, 'rate_coeffs', rate_coeffs,
                                     'Rate Coefficients vs Reduced Field',
                                     'Rate Coefficient (m³s⁻¹)', log_y=True)
        plt.savefig(plots_dir / 'rate_coeffs_evolution.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    # Plot power balance terms evolution
    power_terms = ['Field', 'Elastic collisions (net)', 'CAR (net)', 'Excitation collisions (net)']
    if any(term in data['power_balance']['variable'] for term in power_terms):  # Only plot if we have power terms
        fig = plot_parameter_evolution(data, 'power_balance', power_terms,
                                     'Power Balance Terms vs Reduced Field',
                                     'Power (eVm³s⁻¹)', log_y=True)
        plt.savefig(plots_dir / 'power_balance_evolution.png', dpi=300, bbox_inches='tight')
        plt.close()
        
        # Plot relative differences for power balance
        fig = plot_relative_difference(data, 'power_balance', power_terms,
                                     'Relative Difference in Power Balance Terms')
        plt.savefig(plots_dir / 'power_balance_difference.png', dpi=300, bbox_inches='tight')
        plt.close()

if __name__ == '__main__':
    main() 