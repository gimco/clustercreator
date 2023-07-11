
def parse_lines(data):
    total_seconds = int(data[-1][0].split(':')[0]) * 60 + int(data[-1][0].split(':')[1])
    result = []
    for i in range(len(data)-1):
        current_time = int(data[i][0].split(':')[0]) * 60 + int(data[i][0].split(':')[1])
        next_time = int(data[i+1][0].split(':')[0]) * 60 + int(data[i+1][0].split(':')[1])
        seconds = next_time - current_time
        percentage = int((current_time / total_seconds) * 100)
        next_percentage = int((next_time / total_seconds) * 100) - 1
        if i == 0:
            result.append((0, percentage - 1, current_time, 'Inicializando', '@#-'))
        result.append((percentage, next_percentage, seconds, data[i][1], data[i][2]))
    
    result.append((100, 0, 0, data[-1][1], data[-1][2]))

    return result

def estimated_progress(lines):
    response = patterns[0]

    for line in lines:
        for i in range(len(patterns)):
            if patterns[i][4] in line:
                response = patterns[i]

    return {
        'percentage_start': response[0],
        'percentage_end': response[1],
        'seconds': response[2],
        'message': response[3],
    }


patterns = parse_lines([
    ('00:07', 'Creando VPC', 'aws_vpc.vpc: Creating'),
    ('00:21', 'Creando subredes', 'aws_security_group.instance-sg: Creating...'),
    ('00:33', 'Creando instancias', 'aws_instance.instance[0]: Creating...'),
    ('00:46', 'Finalizado', 'Apply complete'),
])
