import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import tensorflow as tf


from tests.test_estimate import test_estimate_macs, test_estimate_ram, test_estimate_rom
from tests.test_metrics import test_metrics_precision, test_metrics_recall, test_metrics_f1_score
from tests.test_callbacks import test_callbacks_early_stopping

if __name__ == "__main__":
    test_estimate_macs()
    print("test_estimate_macs passed")
    test_estimate_rom()
    print("test_estimate_rom passed")
    test_estimate_ram()
    print("test_estimate_ram passed")
    test_metrics_precision()
    print("test_metrics_precision passed")
    test_metrics_recall()
    print("test_metrics_recall passed")
    test_metrics_f1_score()
    print("test_metrics_f1_score passed")
    test_callbacks_early_stopping()
    print("test_callbacks_early_stopping passed")
    print("All tests passed!")